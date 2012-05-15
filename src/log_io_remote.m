/*
 * Copyright (C) 2010 Mail.RU
 * Copyright (C) 2010 Yuriy Vostrikov
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
#include "log_io.h"
#include "fiber.h"

#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <errno.h>

#include <say.h>
#include <pickle.h>
#include <net_io.h>

static int
remote_apply_row(struct recovery_state *r, struct tbuf *row);

static CoConnection *conn = nil;

static void
close_connection()
{
	[conn detachWorker];
	[conn close];
	[conn free];
	conn = nil;
}

static struct tbuf *
remote_row_reader_v11(CoConnection *conn)
{
	@try {
		ssize_t to_read = sizeof(struct row_v11) - fiber->rbuf->size;
		if (to_read > 0) {
			[conn coReadAhead: fiber->rbuf :to_read];
		}

		ssize_t request_len = row_v11(fiber->rbuf)->len + sizeof(struct row_v11);
		to_read = request_len - fiber->rbuf->size;
		if (to_read > 0) {
			[conn coReadAhead: fiber->rbuf :to_read];
		}

		say_warn("read row bytes:%" PRI_SSZ, request_len);
		return tbuf_split(fiber->rbuf, request_len);
	}
	@catch (SocketEOF *) {
		say_error("unexpected eof reading row header");
		@throw;
	}
}

static struct tbuf *
remote_read_row(struct sockaddr_in *remote_addr, i64 initial_lsn)
{
	bool warning_said = false;
	const int reconnect_delay = 1;
	const char *err = NULL;

	for (;;) {
		@try {
			if (conn == nil) {
				err = "can't connect to master";
				conn = [CoConnection connect: remote_addr];
				[conn attachWorker: fiber];

				err = "can't write version";
				[conn coWrite: &initial_lsn :sizeof(initial_lsn)];

				u32 version;
				err = "can't read version";
				[conn coRead: &version :sizeof(version)];
				if (version != default_version) {
					err = "remote version mismatch";
					goto err;
				}

				say_crit("successfully connected to master");
				say_crit("starting replication from lsn:%" PRIi64, initial_lsn);
				warning_said = false;
			}

			err = "can't read row";
			return remote_row_reader_v11(conn);
		}
		@catch (SocketError *e) {
			[e log];
		}

	      err:
		if (err != NULL && !warning_said) {
			say_info("%s", err);
			say_info("will retry every %i second", reconnect_delay);
			warning_said = true;
		}

		close_connection();
		fiber_sleep(reconnect_delay);
	}
}

static void
pull_from_remote(void *state)
{
	struct recovery_state *r = state;
	struct tbuf *row;

	@try {
		for (;;) {
			fiber_setcancelstate(true);
			row = remote_read_row(&r->remote_addr, r->confirmed_lsn + 1);
			fiber_setcancelstate(false);

			r->recovery_lag = ev_now() - row_v11(row)->tm;
			r->recovery_last_update_tstamp = ev_now();

			if (remote_apply_row(r, row) < 0) {
				close_connection();
				continue;
			}

			fiber_gc();
		}
	}
	@finally {
		close_connection();
	}
}

static int
remote_apply_row(struct recovery_state *r, struct tbuf *row)
{
	struct tbuf *data;
	i64 lsn = row_v11(row)->lsn;
	u16 tag;
	u16 op;

	/* save row data since wal_row_handler may clobber it */
	data = tbuf_alloc(row->pool);
	tbuf_append(data, row_v11(row)->data, row_v11(row)->len);

	if (r->row_handler(r, row) < 0)
		panic("replication failure: can't apply row");

	tag = read_u16(data);
	(void)read_u64(data); /* drop the cookie */
	op = read_u16(data);

	if (wal_write(r, tag, op, r->cookie, lsn, data))
		panic("replication failure: can't write row to WAL");

	next_lsn(r, lsn);
	confirm_lsn(r, lsn);

	return 0;
}

void
recovery_follow_remote(struct recovery_state *r, const char *remote)
{
	char name[FIBER_NAME_MAXLEN];
	char ip_addr[32];
	int port;
	int rc;
	struct fiber *f;
	struct in_addr server;

	assert(r->remote_recovery == NULL);

	say_crit("initializing the replica, WAL master %s", remote);
	snprintf(name, sizeof(name), "replica/%s", remote);

	f = fiber_create(name, -1, pull_from_remote, r);
	if (f == NULL)
		return;

	rc = sscanf(remote, "%31[^:]:%i", ip_addr, &port);
	assert(rc == 2);
	(void)rc;

	if (inet_aton(ip_addr, &server) < 0) {
		say_syserror("inet_aton: %s", ip_addr);
		return;
	}

	memset(&r->remote_addr, 0, sizeof(r->remote_addr));
	r->remote_addr.sin_family = AF_INET;
	memcpy(&r->remote_addr.sin_addr.s_addr, &server, sizeof(server));
	r->remote_addr.sin_port = htons(port);
	memcpy(&r->cookie, &r->remote_addr, MIN(sizeof(r->cookie), sizeof(r->remote_addr)));
	fiber_call(f);
	r->remote_recovery = f;
}

void
recovery_stop_remote(struct recovery_state *r)
{
	say_info("shutting down the replica");
	fiber_cancel(r->remote_recovery);
	r->remote_recovery = NULL;
	memset(&r->remote_addr, 0, sizeof(r->remote_addr));
}
