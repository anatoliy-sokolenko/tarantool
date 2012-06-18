
#line 1 "src/admin.rl"
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

#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdlib.h>

#include <net_io.h>
#include <sock.h>
#include <fiber.h>
#include <palloc.h>
#include <salloc.h>
#include <say.h>
#include <stat.h>
#include <tarantool.h>
#include <tarantool_lua.h>
#include <recovery.h>
#include TARANTOOL_CONFIG
#include <tbuf.h>
#include <util.h>
#include <errinj.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

static const char *help =
	"available commands:" CRLF
	" - help" CRLF
	" - exit" CRLF
	" - show info" CRLF
	" - show fiber" CRLF
	" - show configuration" CRLF
	" - show slab" CRLF
	" - show palloc" CRLF
	" - show net" CRLF
	" - show stat" CRLF
	" - save coredump" CRLF
	" - save snapshot" CRLF
	" - lua command" CRLF
	" - reload configuration" CRLF
	" - show injections (debug mode only)" CRLF
	" - set injection <name> <state> (debug mode only)" CRLF;

static const char *unknown_command = "unknown command. try typing help." CRLF;


#line 76 "src/admin.m"
static const int admin_start = 1;
static const int admin_first_final = 138;
static const int admin_error = 0;

static const int admin_en_main = 1;


#line 75 "src/admin.rl"



static void
end(struct tbuf *out)
{
	tbuf_printf(out, "..." CRLF);
}

static void
start(struct tbuf *out)
{
	tbuf_printf(out, "---" CRLF);
}

static void
ok(struct tbuf *out)
{
	start(out);
	tbuf_printf(out, "ok" CRLF);
	end(out);
}

static void
fail(struct tbuf *out, struct tbuf *err)
{
	start(out);
	tbuf_printf(out, "fail:%.*s" CRLF, err->size, (char *)err->data);
	end(out);
}

static void
tarantool_info(struct tbuf *out)
{
	tbuf_printf(out, "info:" CRLF);
	tbuf_printf(out, "  version: \"%s\"" CRLF, tarantool_version());
	tbuf_printf(out, "  uptime: %i" CRLF, (int)tarantool_uptime());
	tbuf_printf(out, "  pid: %i" CRLF, getpid());
	tbuf_printf(out, "  logger_pid: %i" CRLF, logger_pid);
	tbuf_printf(out, "  lsn: %" PRIi64 CRLF,
		    recovery_state->confirmed_lsn);
	tbuf_printf(out, "  recovery_lag: %.3f" CRLF,
		    recovery_state->remote ? 
		    recovery_state->remote->recovery_lag : 0);
	tbuf_printf(out, "  recovery_last_update: %.3f" CRLF,
		    recovery_state->remote ?
		    recovery_state->remote->recovery_last_update_tstamp :0);
	mod_info(out);
	const char *path = cfg_filename_fullpath;
	if (path == NULL)
		path = cfg_filename;
	tbuf_printf(out, "  config: \"%s\"" CRLF, path);
}

static void
admin_dispatch(ServiceConnection *conn, lua_State *L)
{
	struct tbuf *out = tbuf_alloc(fiber->gc_pool);
	struct tbuf *err = tbuf_alloc(fiber->gc_pool);
	int cs;
	char *p, *pe;
	char *strstart, *strend;
	bool state;

	while ((pe = memchr(fiber->rbuf->data, '\n', fiber->rbuf->size)) == NULL) {
		[conn coReadAhead: fiber->rbuf :1];
	}

	pe++;
	p = fiber->rbuf->data;

	
#line 157 "src/admin.m"
	{
	cs = admin_start;
	}

#line 162 "src/admin.m"
	{
	if ( p == pe )
		goto _test_eof;
	switch ( cs )
	{
case 1:
	switch( (*p) ) {
		case 99: goto st2;
		case 101: goto st13;
		case 104: goto st17;
		case 108: goto st21;
		case 113: goto st27;
		case 114: goto st28;
		case 115: goto st48;
	}
	goto st0;
st0:
cs = 0;
	goto _out;
st2:
	if ( ++p == pe )
		goto _test_eof2;
case 2:
	if ( (*p) == 104 )
		goto st3;
	goto st0;
st3:
	if ( ++p == pe )
		goto _test_eof3;
case 3:
	switch( (*p) ) {
		case 32: goto st4;
		case 101: goto st10;
	}
	goto st0;
st4:
	if ( ++p == pe )
		goto _test_eof4;
case 4:
	switch( (*p) ) {
		case 32: goto st4;
		case 115: goto st5;
	}
	goto st0;
st5:
	if ( ++p == pe )
		goto _test_eof5;
case 5:
	if ( (*p) == 108 )
		goto st6;
	goto st0;
st6:
	if ( ++p == pe )
		goto _test_eof6;
case 6:
	switch( (*p) ) {
		case 10: goto tr13;
		case 13: goto tr14;
		case 97: goto st8;
	}
	goto st0;
tr13:
#line 258 "src/admin.rl"
	{slab_validate(); ok(out);}
	goto st138;
tr20:
#line 245 "src/admin.rl"
	{return;}
	goto st138;
tr25:
#line 171 "src/admin.rl"
	{
			start(out);
			tbuf_append(out, help, strlen(help));
			end(out);
		}
	goto st138;
tr36:
#line 231 "src/admin.rl"
	{strend = p;}
#line 177 "src/admin.rl"
	{
			strstart[strend-strstart]='\0';
			start(out);
			tarantool_lua(L, out, strstart);
			end(out);
		}
	goto st138;
tr43:
#line 184 "src/admin.rl"
	{
			if (reload_cfg(err))
				fail(out, err);
			else
				ok(out);
		}
	goto st138;
tr67:
#line 256 "src/admin.rl"
	{coredump(60); ok(out);}
	goto st138;
tr76:
#line 191 "src/admin.rl"
	{
			int ret = snapshot(NULL, 0);

			if (ret == 0)
				ok(out);
			else {
				tbuf_printf(err, " can't save snapshot, errno %d (%s)",
					    ret, strerror(ret));

				fail(out, err);
			}
		}
	goto st138;
tr98:
#line 241 "src/admin.rl"
	{ state = false; }
#line 204 "src/admin.rl"
	{
			strstart[strend-strstart] = '\0';
			if (errinj_set_byname(strstart, state)) {
				tbuf_printf(err, "can't find error injection '%s'", strstart);
				fail(out, err);
			} else {
				ok(out);
			}
		}
	goto st138;
tr101:
#line 240 "src/admin.rl"
	{ state = true; }
#line 204 "src/admin.rl"
	{
			strstart[strend-strstart] = '\0';
			if (errinj_set_byname(strstart, state)) {
				tbuf_printf(err, "can't find error injection '%s'", strstart);
				fail(out, err);
			} else {
				ok(out);
			}
		}
	goto st138;
tr118:
#line 147 "src/admin.rl"
	{
			tarantool_cfg_iterator_t *i;
			char *key, *value;

			start(out);
			tbuf_printf(out, "configuration:" CRLF);
			i = tarantool_cfg_iterator_init();
			while ((key = tarantool_cfg_iterator_next(i, &cfg, &value)) != NULL) {
				if (value) {
					tbuf_printf(out, "  %s: \"%s\"" CRLF, key, value);
					free(value);
				} else {
					tbuf_printf(out, "  %s: (null)" CRLF, key);
				}
			}
			end(out);
		}
	goto st138;
tr132:
#line 248 "src/admin.rl"
	{start(out); fiber_info(out); end(out);}
	goto st138;
tr138:
#line 247 "src/admin.rl"
	{start(out); tarantool_info(out); end(out);}
	goto st138;
tr147:
#line 165 "src/admin.rl"
	{
			start(out);
			errinj_info(out);
			end(out);
		}
	goto st138;
tr153:
#line 252 "src/admin.rl"
	{start(out); net_io_info(out);end(out);}
	goto st138;
tr157:
#line 251 "src/admin.rl"
	{start(out); palloc_stat(out); end(out);}
	goto st138;
tr165:
#line 250 "src/admin.rl"
	{start(out); slab_stat(out); end(out);}
	goto st138;
tr169:
#line 253 "src/admin.rl"
	{start(out); stat_print(out);end(out);}
	goto st138;
st138:
	if ( ++p == pe )
		goto _test_eof138;
case 138:
#line 363 "src/admin.m"
	goto st0;
tr14:
#line 258 "src/admin.rl"
	{slab_validate(); ok(out);}
	goto st7;
tr21:
#line 245 "src/admin.rl"
	{return;}
	goto st7;
tr26:
#line 171 "src/admin.rl"
	{
			start(out);
			tbuf_append(out, help, strlen(help));
			end(out);
		}
	goto st7;
tr37:
#line 231 "src/admin.rl"
	{strend = p;}
#line 177 "src/admin.rl"
	{
			strstart[strend-strstart]='\0';
			start(out);
			tarantool_lua(L, out, strstart);
			end(out);
		}
	goto st7;
tr44:
#line 184 "src/admin.rl"
	{
			if (reload_cfg(err))
				fail(out, err);
			else
				ok(out);
		}
	goto st7;
tr68:
#line 256 "src/admin.rl"
	{coredump(60); ok(out);}
	goto st7;
tr77:
#line 191 "src/admin.rl"
	{
			int ret = snapshot(NULL, 0);

			if (ret == 0)
				ok(out);
			else {
				tbuf_printf(err, " can't save snapshot, errno %d (%s)",
					    ret, strerror(ret));

				fail(out, err);
			}
		}
	goto st7;
tr99:
#line 241 "src/admin.rl"
	{ state = false; }
#line 204 "src/admin.rl"
	{
			strstart[strend-strstart] = '\0';
			if (errinj_set_byname(strstart, state)) {
				tbuf_printf(err, "can't find error injection '%s'", strstart);
				fail(out, err);
			} else {
				ok(out);
			}
		}
	goto st7;
tr102:
#line 240 "src/admin.rl"
	{ state = true; }
#line 204 "src/admin.rl"
	{
			strstart[strend-strstart] = '\0';
			if (errinj_set_byname(strstart, state)) {
				tbuf_printf(err, "can't find error injection '%s'", strstart);
				fail(out, err);
			} else {
				ok(out);
			}
		}
	goto st7;
tr119:
#line 147 "src/admin.rl"
	{
			tarantool_cfg_iterator_t *i;
			char *key, *value;

			start(out);
			tbuf_printf(out, "configuration:" CRLF);
			i = tarantool_cfg_iterator_init();
			while ((key = tarantool_cfg_iterator_next(i, &cfg, &value)) != NULL) {
				if (value) {
					tbuf_printf(out, "  %s: \"%s\"" CRLF, key, value);
					free(value);
				} else {
					tbuf_printf(out, "  %s: (null)" CRLF, key);
				}
			}
			end(out);
		}
	goto st7;
tr133:
#line 248 "src/admin.rl"
	{start(out); fiber_info(out); end(out);}
	goto st7;
tr139:
#line 247 "src/admin.rl"
	{start(out); tarantool_info(out); end(out);}
	goto st7;
tr148:
#line 165 "src/admin.rl"
	{
			start(out);
			errinj_info(out);
			end(out);
		}
	goto st7;
tr154:
#line 252 "src/admin.rl"
	{start(out); net_io_info(out);end(out);}
	goto st7;
tr158:
#line 251 "src/admin.rl"
	{start(out); palloc_stat(out); end(out);}
	goto st7;
tr166:
#line 250 "src/admin.rl"
	{start(out); slab_stat(out); end(out);}
	goto st7;
tr170:
#line 253 "src/admin.rl"
	{start(out); stat_print(out);end(out);}
	goto st7;
st7:
	if ( ++p == pe )
		goto _test_eof7;
case 7:
#line 504 "src/admin.m"
	if ( (*p) == 10 )
		goto st138;
	goto st0;
st8:
	if ( ++p == pe )
		goto _test_eof8;
case 8:
	switch( (*p) ) {
		case 10: goto tr13;
		case 13: goto tr14;
		case 98: goto st9;
	}
	goto st0;
st9:
	if ( ++p == pe )
		goto _test_eof9;
case 9:
	switch( (*p) ) {
		case 10: goto tr13;
		case 13: goto tr14;
	}
	goto st0;
st10:
	if ( ++p == pe )
		goto _test_eof10;
case 10:
	switch( (*p) ) {
		case 32: goto st4;
		case 99: goto st11;
	}
	goto st0;
st11:
	if ( ++p == pe )
		goto _test_eof11;
case 11:
	switch( (*p) ) {
		case 32: goto st4;
		case 107: goto st12;
	}
	goto st0;
st12:
	if ( ++p == pe )
		goto _test_eof12;
case 12:
	if ( (*p) == 32 )
		goto st4;
	goto st0;
st13:
	if ( ++p == pe )
		goto _test_eof13;
case 13:
	switch( (*p) ) {
		case 10: goto tr20;
		case 13: goto tr21;
		case 120: goto st14;
	}
	goto st0;
st14:
	if ( ++p == pe )
		goto _test_eof14;
case 14:
	switch( (*p) ) {
		case 10: goto tr20;
		case 13: goto tr21;
		case 105: goto st15;
	}
	goto st0;
st15:
	if ( ++p == pe )
		goto _test_eof15;
case 15:
	switch( (*p) ) {
		case 10: goto tr20;
		case 13: goto tr21;
		case 116: goto st16;
	}
	goto st0;
st16:
	if ( ++p == pe )
		goto _test_eof16;
case 16:
	switch( (*p) ) {
		case 10: goto tr20;
		case 13: goto tr21;
	}
	goto st0;
st17:
	if ( ++p == pe )
		goto _test_eof17;
case 17:
	switch( (*p) ) {
		case 10: goto tr25;
		case 13: goto tr26;
		case 101: goto st18;
	}
	goto st0;
st18:
	if ( ++p == pe )
		goto _test_eof18;
case 18:
	switch( (*p) ) {
		case 10: goto tr25;
		case 13: goto tr26;
		case 108: goto st19;
	}
	goto st0;
st19:
	if ( ++p == pe )
		goto _test_eof19;
case 19:
	switch( (*p) ) {
		case 10: goto tr25;
		case 13: goto tr26;
		case 112: goto st20;
	}
	goto st0;
st20:
	if ( ++p == pe )
		goto _test_eof20;
case 20:
	switch( (*p) ) {
		case 10: goto tr25;
		case 13: goto tr26;
	}
	goto st0;
st21:
	if ( ++p == pe )
		goto _test_eof21;
case 21:
	if ( (*p) == 117 )
		goto st22;
	goto st0;
st22:
	if ( ++p == pe )
		goto _test_eof22;
case 22:
	switch( (*p) ) {
		case 32: goto st23;
		case 97: goto st26;
	}
	goto st0;
st23:
	if ( ++p == pe )
		goto _test_eof23;
case 23:
	switch( (*p) ) {
		case 10: goto st0;
		case 13: goto st0;
		case 32: goto tr34;
	}
	goto tr33;
tr33:
#line 231 "src/admin.rl"
	{strstart = p;}
	goto st24;
st24:
	if ( ++p == pe )
		goto _test_eof24;
case 24:
#line 664 "src/admin.m"
	switch( (*p) ) {
		case 10: goto tr36;
		case 13: goto tr37;
	}
	goto st24;
tr34:
#line 231 "src/admin.rl"
	{strstart = p;}
	goto st25;
st25:
	if ( ++p == pe )
		goto _test_eof25;
case 25:
#line 678 "src/admin.m"
	switch( (*p) ) {
		case 10: goto tr36;
		case 13: goto tr37;
		case 32: goto tr34;
	}
	goto tr33;
st26:
	if ( ++p == pe )
		goto _test_eof26;
case 26:
	if ( (*p) == 32 )
		goto st23;
	goto st0;
st27:
	if ( ++p == pe )
		goto _test_eof27;
case 27:
	switch( (*p) ) {
		case 10: goto tr20;
		case 13: goto tr21;
		case 117: goto st14;
	}
	goto st0;
st28:
	if ( ++p == pe )
		goto _test_eof28;
case 28:
	if ( (*p) == 101 )
		goto st29;
	goto st0;
st29:
	if ( ++p == pe )
		goto _test_eof29;
case 29:
	switch( (*p) ) {
		case 32: goto st30;
		case 108: goto st44;
	}
	goto st0;
st30:
	if ( ++p == pe )
		goto _test_eof30;
case 30:
	switch( (*p) ) {
		case 32: goto st30;
		case 99: goto st31;
	}
	goto st0;
st31:
	if ( ++p == pe )
		goto _test_eof31;
case 31:
	if ( (*p) == 111 )
		goto st32;
	goto st0;
st32:
	if ( ++p == pe )
		goto _test_eof32;
case 32:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 110: goto st33;
	}
	goto st0;
st33:
	if ( ++p == pe )
		goto _test_eof33;
case 33:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 102: goto st34;
	}
	goto st0;
st34:
	if ( ++p == pe )
		goto _test_eof34;
case 34:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 105: goto st35;
	}
	goto st0;
st35:
	if ( ++p == pe )
		goto _test_eof35;
case 35:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 103: goto st36;
	}
	goto st0;
st36:
	if ( ++p == pe )
		goto _test_eof36;
case 36:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 117: goto st37;
	}
	goto st0;
st37:
	if ( ++p == pe )
		goto _test_eof37;
case 37:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 114: goto st38;
	}
	goto st0;
st38:
	if ( ++p == pe )
		goto _test_eof38;
case 38:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 97: goto st39;
	}
	goto st0;
st39:
	if ( ++p == pe )
		goto _test_eof39;
case 39:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 116: goto st40;
	}
	goto st0;
st40:
	if ( ++p == pe )
		goto _test_eof40;
case 40:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 105: goto st41;
	}
	goto st0;
st41:
	if ( ++p == pe )
		goto _test_eof41;
case 41:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 111: goto st42;
	}
	goto st0;
st42:
	if ( ++p == pe )
		goto _test_eof42;
case 42:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
		case 110: goto st43;
	}
	goto st0;
st43:
	if ( ++p == pe )
		goto _test_eof43;
case 43:
	switch( (*p) ) {
		case 10: goto tr43;
		case 13: goto tr44;
	}
	goto st0;
st44:
	if ( ++p == pe )
		goto _test_eof44;
case 44:
	switch( (*p) ) {
		case 32: goto st30;
		case 111: goto st45;
	}
	goto st0;
st45:
	if ( ++p == pe )
		goto _test_eof45;
case 45:
	switch( (*p) ) {
		case 32: goto st30;
		case 97: goto st46;
	}
	goto st0;
st46:
	if ( ++p == pe )
		goto _test_eof46;
case 46:
	switch( (*p) ) {
		case 32: goto st30;
		case 100: goto st47;
	}
	goto st0;
st47:
	if ( ++p == pe )
		goto _test_eof47;
case 47:
	if ( (*p) == 32 )
		goto st30;
	goto st0;
st48:
	if ( ++p == pe )
		goto _test_eof48;
case 48:
	switch( (*p) ) {
		case 97: goto st49;
		case 101: goto st69;
		case 104: goto st88;
	}
	goto st0;
st49:
	if ( ++p == pe )
		goto _test_eof49;
case 49:
	switch( (*p) ) {
		case 32: goto st50;
		case 118: goto st67;
	}
	goto st0;
st50:
	if ( ++p == pe )
		goto _test_eof50;
case 50:
	switch( (*p) ) {
		case 32: goto st50;
		case 99: goto st51;
		case 115: goto st59;
	}
	goto st0;
st51:
	if ( ++p == pe )
		goto _test_eof51;
case 51:
	if ( (*p) == 111 )
		goto st52;
	goto st0;
st52:
	if ( ++p == pe )
		goto _test_eof52;
case 52:
	switch( (*p) ) {
		case 10: goto tr67;
		case 13: goto tr68;
		case 114: goto st53;
	}
	goto st0;
st53:
	if ( ++p == pe )
		goto _test_eof53;
case 53:
	switch( (*p) ) {
		case 10: goto tr67;
		case 13: goto tr68;
		case 101: goto st54;
	}
	goto st0;
st54:
	if ( ++p == pe )
		goto _test_eof54;
case 54:
	switch( (*p) ) {
		case 10: goto tr67;
		case 13: goto tr68;
		case 100: goto st55;
	}
	goto st0;
st55:
	if ( ++p == pe )
		goto _test_eof55;
case 55:
	switch( (*p) ) {
		case 10: goto tr67;
		case 13: goto tr68;
		case 117: goto st56;
	}
	goto st0;
st56:
	if ( ++p == pe )
		goto _test_eof56;
case 56:
	switch( (*p) ) {
		case 10: goto tr67;
		case 13: goto tr68;
		case 109: goto st57;
	}
	goto st0;
st57:
	if ( ++p == pe )
		goto _test_eof57;
case 57:
	switch( (*p) ) {
		case 10: goto tr67;
		case 13: goto tr68;
		case 112: goto st58;
	}
	goto st0;
st58:
	if ( ++p == pe )
		goto _test_eof58;
case 58:
	switch( (*p) ) {
		case 10: goto tr67;
		case 13: goto tr68;
	}
	goto st0;
st59:
	if ( ++p == pe )
		goto _test_eof59;
case 59:
	if ( (*p) == 110 )
		goto st60;
	goto st0;
st60:
	if ( ++p == pe )
		goto _test_eof60;
case 60:
	switch( (*p) ) {
		case 10: goto tr76;
		case 13: goto tr77;
		case 97: goto st61;
	}
	goto st0;
st61:
	if ( ++p == pe )
		goto _test_eof61;
case 61:
	switch( (*p) ) {
		case 10: goto tr76;
		case 13: goto tr77;
		case 112: goto st62;
	}
	goto st0;
st62:
	if ( ++p == pe )
		goto _test_eof62;
case 62:
	switch( (*p) ) {
		case 10: goto tr76;
		case 13: goto tr77;
		case 115: goto st63;
	}
	goto st0;
st63:
	if ( ++p == pe )
		goto _test_eof63;
case 63:
	switch( (*p) ) {
		case 10: goto tr76;
		case 13: goto tr77;
		case 104: goto st64;
	}
	goto st0;
st64:
	if ( ++p == pe )
		goto _test_eof64;
case 64:
	switch( (*p) ) {
		case 10: goto tr76;
		case 13: goto tr77;
		case 111: goto st65;
	}
	goto st0;
st65:
	if ( ++p == pe )
		goto _test_eof65;
case 65:
	switch( (*p) ) {
		case 10: goto tr76;
		case 13: goto tr77;
		case 116: goto st66;
	}
	goto st0;
st66:
	if ( ++p == pe )
		goto _test_eof66;
case 66:
	switch( (*p) ) {
		case 10: goto tr76;
		case 13: goto tr77;
	}
	goto st0;
st67:
	if ( ++p == pe )
		goto _test_eof67;
case 67:
	switch( (*p) ) {
		case 32: goto st50;
		case 101: goto st68;
	}
	goto st0;
st68:
	if ( ++p == pe )
		goto _test_eof68;
case 68:
	if ( (*p) == 32 )
		goto st50;
	goto st0;
st69:
	if ( ++p == pe )
		goto _test_eof69;
case 69:
	switch( (*p) ) {
		case 32: goto st70;
		case 116: goto st87;
	}
	goto st0;
st70:
	if ( ++p == pe )
		goto _test_eof70;
case 70:
	switch( (*p) ) {
		case 32: goto st70;
		case 105: goto st71;
	}
	goto st0;
st71:
	if ( ++p == pe )
		goto _test_eof71;
case 71:
	if ( (*p) == 110 )
		goto st72;
	goto st0;
st72:
	if ( ++p == pe )
		goto _test_eof72;
case 72:
	switch( (*p) ) {
		case 32: goto st73;
		case 106: goto st80;
	}
	goto st0;
st73:
	if ( ++p == pe )
		goto _test_eof73;
case 73:
	if ( (*p) == 32 )
		goto st73;
	if ( 33 <= (*p) && (*p) <= 126 )
		goto tr91;
	goto st0;
tr91:
#line 239 "src/admin.rl"
	{ strstart = p; }
	goto st74;
st74:
	if ( ++p == pe )
		goto _test_eof74;
case 74:
#line 1135 "src/admin.m"
	if ( (*p) == 32 )
		goto tr92;
	if ( 33 <= (*p) && (*p) <= 126 )
		goto st74;
	goto st0;
tr92:
#line 239 "src/admin.rl"
	{ strend = p; }
	goto st75;
st75:
	if ( ++p == pe )
		goto _test_eof75;
case 75:
#line 1149 "src/admin.m"
	switch( (*p) ) {
		case 32: goto st75;
		case 111: goto st76;
	}
	goto st0;
st76:
	if ( ++p == pe )
		goto _test_eof76;
case 76:
	switch( (*p) ) {
		case 102: goto st77;
		case 110: goto st79;
	}
	goto st0;
st77:
	if ( ++p == pe )
		goto _test_eof77;
case 77:
	switch( (*p) ) {
		case 10: goto tr98;
		case 13: goto tr99;
		case 102: goto st78;
	}
	goto st0;
st78:
	if ( ++p == pe )
		goto _test_eof78;
case 78:
	switch( (*p) ) {
		case 10: goto tr98;
		case 13: goto tr99;
	}
	goto st0;
st79:
	if ( ++p == pe )
		goto _test_eof79;
case 79:
	switch( (*p) ) {
		case 10: goto tr101;
		case 13: goto tr102;
	}
	goto st0;
st80:
	if ( ++p == pe )
		goto _test_eof80;
case 80:
	switch( (*p) ) {
		case 32: goto st73;
		case 101: goto st81;
	}
	goto st0;
st81:
	if ( ++p == pe )
		goto _test_eof81;
case 81:
	switch( (*p) ) {
		case 32: goto st73;
		case 99: goto st82;
	}
	goto st0;
st82:
	if ( ++p == pe )
		goto _test_eof82;
case 82:
	switch( (*p) ) {
		case 32: goto st73;
		case 116: goto st83;
	}
	goto st0;
st83:
	if ( ++p == pe )
		goto _test_eof83;
case 83:
	switch( (*p) ) {
		case 32: goto st73;
		case 105: goto st84;
	}
	goto st0;
st84:
	if ( ++p == pe )
		goto _test_eof84;
case 84:
	switch( (*p) ) {
		case 32: goto st73;
		case 111: goto st85;
	}
	goto st0;
st85:
	if ( ++p == pe )
		goto _test_eof85;
case 85:
	switch( (*p) ) {
		case 32: goto st73;
		case 110: goto st86;
	}
	goto st0;
st86:
	if ( ++p == pe )
		goto _test_eof86;
case 86:
	if ( (*p) == 32 )
		goto st73;
	goto st0;
st87:
	if ( ++p == pe )
		goto _test_eof87;
case 87:
	if ( (*p) == 32 )
		goto st70;
	goto st0;
st88:
	if ( ++p == pe )
		goto _test_eof88;
case 88:
	switch( (*p) ) {
		case 32: goto st89;
		case 111: goto st136;
	}
	goto st0;
st89:
	if ( ++p == pe )
		goto _test_eof89;
case 89:
	switch( (*p) ) {
		case 32: goto st89;
		case 99: goto st90;
		case 102: goto st103;
		case 105: goto st108;
		case 110: goto st120;
		case 112: goto st123;
		case 115: goto st129;
	}
	goto st0;
st90:
	if ( ++p == pe )
		goto _test_eof90;
case 90:
	if ( (*p) == 111 )
		goto st91;
	goto st0;
st91:
	if ( ++p == pe )
		goto _test_eof91;
case 91:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 110: goto st92;
	}
	goto st0;
st92:
	if ( ++p == pe )
		goto _test_eof92;
case 92:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 102: goto st93;
	}
	goto st0;
st93:
	if ( ++p == pe )
		goto _test_eof93;
case 93:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 105: goto st94;
	}
	goto st0;
st94:
	if ( ++p == pe )
		goto _test_eof94;
case 94:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 103: goto st95;
	}
	goto st0;
st95:
	if ( ++p == pe )
		goto _test_eof95;
case 95:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 117: goto st96;
	}
	goto st0;
st96:
	if ( ++p == pe )
		goto _test_eof96;
case 96:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 114: goto st97;
	}
	goto st0;
st97:
	if ( ++p == pe )
		goto _test_eof97;
case 97:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 97: goto st98;
	}
	goto st0;
st98:
	if ( ++p == pe )
		goto _test_eof98;
case 98:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 116: goto st99;
	}
	goto st0;
st99:
	if ( ++p == pe )
		goto _test_eof99;
case 99:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 105: goto st100;
	}
	goto st0;
st100:
	if ( ++p == pe )
		goto _test_eof100;
case 100:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 111: goto st101;
	}
	goto st0;
st101:
	if ( ++p == pe )
		goto _test_eof101;
case 101:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
		case 110: goto st102;
	}
	goto st0;
st102:
	if ( ++p == pe )
		goto _test_eof102;
case 102:
	switch( (*p) ) {
		case 10: goto tr118;
		case 13: goto tr119;
	}
	goto st0;
st103:
	if ( ++p == pe )
		goto _test_eof103;
case 103:
	if ( (*p) == 105 )
		goto st104;
	goto st0;
st104:
	if ( ++p == pe )
		goto _test_eof104;
case 104:
	switch( (*p) ) {
		case 10: goto tr132;
		case 13: goto tr133;
		case 98: goto st105;
	}
	goto st0;
st105:
	if ( ++p == pe )
		goto _test_eof105;
case 105:
	switch( (*p) ) {
		case 10: goto tr132;
		case 13: goto tr133;
		case 101: goto st106;
	}
	goto st0;
st106:
	if ( ++p == pe )
		goto _test_eof106;
case 106:
	switch( (*p) ) {
		case 10: goto tr132;
		case 13: goto tr133;
		case 114: goto st107;
	}
	goto st0;
st107:
	if ( ++p == pe )
		goto _test_eof107;
case 107:
	switch( (*p) ) {
		case 10: goto tr132;
		case 13: goto tr133;
	}
	goto st0;
st108:
	if ( ++p == pe )
		goto _test_eof108;
case 108:
	if ( (*p) == 110 )
		goto st109;
	goto st0;
st109:
	if ( ++p == pe )
		goto _test_eof109;
case 109:
	switch( (*p) ) {
		case 10: goto tr138;
		case 13: goto tr139;
		case 102: goto st110;
		case 106: goto st112;
		case 115: goto st115;
	}
	goto st0;
st110:
	if ( ++p == pe )
		goto _test_eof110;
case 110:
	switch( (*p) ) {
		case 10: goto tr138;
		case 13: goto tr139;
		case 111: goto st111;
	}
	goto st0;
st111:
	if ( ++p == pe )
		goto _test_eof111;
case 111:
	switch( (*p) ) {
		case 10: goto tr138;
		case 13: goto tr139;
	}
	goto st0;
st112:
	if ( ++p == pe )
		goto _test_eof112;
case 112:
	switch( (*p) ) {
		case 101: goto st113;
		case 115: goto st115;
	}
	goto st0;
st113:
	if ( ++p == pe )
		goto _test_eof113;
case 113:
	switch( (*p) ) {
		case 99: goto st114;
		case 115: goto st115;
	}
	goto st0;
st114:
	if ( ++p == pe )
		goto _test_eof114;
case 114:
	switch( (*p) ) {
		case 115: goto st115;
		case 116: goto st116;
	}
	goto st0;
st115:
	if ( ++p == pe )
		goto _test_eof115;
case 115:
	switch( (*p) ) {
		case 10: goto tr147;
		case 13: goto tr148;
	}
	goto st0;
st116:
	if ( ++p == pe )
		goto _test_eof116;
case 116:
	switch( (*p) ) {
		case 105: goto st117;
		case 115: goto st115;
	}
	goto st0;
st117:
	if ( ++p == pe )
		goto _test_eof117;
case 117:
	switch( (*p) ) {
		case 111: goto st118;
		case 115: goto st115;
	}
	goto st0;
st118:
	if ( ++p == pe )
		goto _test_eof118;
case 118:
	switch( (*p) ) {
		case 110: goto st119;
		case 115: goto st115;
	}
	goto st0;
st119:
	if ( ++p == pe )
		goto _test_eof119;
case 119:
	if ( (*p) == 115 )
		goto st115;
	goto st0;
st120:
	if ( ++p == pe )
		goto _test_eof120;
case 120:
	if ( (*p) == 101 )
		goto st121;
	goto st0;
st121:
	if ( ++p == pe )
		goto _test_eof121;
case 121:
	switch( (*p) ) {
		case 10: goto tr153;
		case 13: goto tr154;
		case 116: goto st122;
	}
	goto st0;
st122:
	if ( ++p == pe )
		goto _test_eof122;
case 122:
	switch( (*p) ) {
		case 10: goto tr153;
		case 13: goto tr154;
	}
	goto st0;
st123:
	if ( ++p == pe )
		goto _test_eof123;
case 123:
	if ( (*p) == 97 )
		goto st124;
	goto st0;
st124:
	if ( ++p == pe )
		goto _test_eof124;
case 124:
	switch( (*p) ) {
		case 10: goto tr157;
		case 13: goto tr158;
		case 108: goto st125;
	}
	goto st0;
st125:
	if ( ++p == pe )
		goto _test_eof125;
case 125:
	switch( (*p) ) {
		case 10: goto tr157;
		case 13: goto tr158;
		case 108: goto st126;
	}
	goto st0;
st126:
	if ( ++p == pe )
		goto _test_eof126;
case 126:
	switch( (*p) ) {
		case 10: goto tr157;
		case 13: goto tr158;
		case 111: goto st127;
	}
	goto st0;
st127:
	if ( ++p == pe )
		goto _test_eof127;
case 127:
	switch( (*p) ) {
		case 10: goto tr157;
		case 13: goto tr158;
		case 99: goto st128;
	}
	goto st0;
st128:
	if ( ++p == pe )
		goto _test_eof128;
case 128:
	switch( (*p) ) {
		case 10: goto tr157;
		case 13: goto tr158;
	}
	goto st0;
st129:
	if ( ++p == pe )
		goto _test_eof129;
case 129:
	switch( (*p) ) {
		case 108: goto st130;
		case 116: goto st133;
	}
	goto st0;
st130:
	if ( ++p == pe )
		goto _test_eof130;
case 130:
	switch( (*p) ) {
		case 10: goto tr165;
		case 13: goto tr166;
		case 97: goto st131;
	}
	goto st0;
st131:
	if ( ++p == pe )
		goto _test_eof131;
case 131:
	switch( (*p) ) {
		case 10: goto tr165;
		case 13: goto tr166;
		case 98: goto st132;
	}
	goto st0;
st132:
	if ( ++p == pe )
		goto _test_eof132;
case 132:
	switch( (*p) ) {
		case 10: goto tr165;
		case 13: goto tr166;
	}
	goto st0;
st133:
	if ( ++p == pe )
		goto _test_eof133;
case 133:
	switch( (*p) ) {
		case 10: goto tr169;
		case 13: goto tr170;
		case 97: goto st134;
	}
	goto st0;
st134:
	if ( ++p == pe )
		goto _test_eof134;
case 134:
	switch( (*p) ) {
		case 10: goto tr169;
		case 13: goto tr170;
		case 116: goto st135;
	}
	goto st0;
st135:
	if ( ++p == pe )
		goto _test_eof135;
case 135:
	switch( (*p) ) {
		case 10: goto tr169;
		case 13: goto tr170;
	}
	goto st0;
st136:
	if ( ++p == pe )
		goto _test_eof136;
case 136:
	switch( (*p) ) {
		case 32: goto st89;
		case 119: goto st137;
	}
	goto st0;
st137:
	if ( ++p == pe )
		goto _test_eof137;
case 137:
	if ( (*p) == 32 )
		goto st89;
	goto st0;
	}
	_test_eof2: cs = 2; goto _test_eof; 
	_test_eof3: cs = 3; goto _test_eof; 
	_test_eof4: cs = 4; goto _test_eof; 
	_test_eof5: cs = 5; goto _test_eof; 
	_test_eof6: cs = 6; goto _test_eof; 
	_test_eof138: cs = 138; goto _test_eof; 
	_test_eof7: cs = 7; goto _test_eof; 
	_test_eof8: cs = 8; goto _test_eof; 
	_test_eof9: cs = 9; goto _test_eof; 
	_test_eof10: cs = 10; goto _test_eof; 
	_test_eof11: cs = 11; goto _test_eof; 
	_test_eof12: cs = 12; goto _test_eof; 
	_test_eof13: cs = 13; goto _test_eof; 
	_test_eof14: cs = 14; goto _test_eof; 
	_test_eof15: cs = 15; goto _test_eof; 
	_test_eof16: cs = 16; goto _test_eof; 
	_test_eof17: cs = 17; goto _test_eof; 
	_test_eof18: cs = 18; goto _test_eof; 
	_test_eof19: cs = 19; goto _test_eof; 
	_test_eof20: cs = 20; goto _test_eof; 
	_test_eof21: cs = 21; goto _test_eof; 
	_test_eof22: cs = 22; goto _test_eof; 
	_test_eof23: cs = 23; goto _test_eof; 
	_test_eof24: cs = 24; goto _test_eof; 
	_test_eof25: cs = 25; goto _test_eof; 
	_test_eof26: cs = 26; goto _test_eof; 
	_test_eof27: cs = 27; goto _test_eof; 
	_test_eof28: cs = 28; goto _test_eof; 
	_test_eof29: cs = 29; goto _test_eof; 
	_test_eof30: cs = 30; goto _test_eof; 
	_test_eof31: cs = 31; goto _test_eof; 
	_test_eof32: cs = 32; goto _test_eof; 
	_test_eof33: cs = 33; goto _test_eof; 
	_test_eof34: cs = 34; goto _test_eof; 
	_test_eof35: cs = 35; goto _test_eof; 
	_test_eof36: cs = 36; goto _test_eof; 
	_test_eof37: cs = 37; goto _test_eof; 
	_test_eof38: cs = 38; goto _test_eof; 
	_test_eof39: cs = 39; goto _test_eof; 
	_test_eof40: cs = 40; goto _test_eof; 
	_test_eof41: cs = 41; goto _test_eof; 
	_test_eof42: cs = 42; goto _test_eof; 
	_test_eof43: cs = 43; goto _test_eof; 
	_test_eof44: cs = 44; goto _test_eof; 
	_test_eof45: cs = 45; goto _test_eof; 
	_test_eof46: cs = 46; goto _test_eof; 
	_test_eof47: cs = 47; goto _test_eof; 
	_test_eof48: cs = 48; goto _test_eof; 
	_test_eof49: cs = 49; goto _test_eof; 
	_test_eof50: cs = 50; goto _test_eof; 
	_test_eof51: cs = 51; goto _test_eof; 
	_test_eof52: cs = 52; goto _test_eof; 
	_test_eof53: cs = 53; goto _test_eof; 
	_test_eof54: cs = 54; goto _test_eof; 
	_test_eof55: cs = 55; goto _test_eof; 
	_test_eof56: cs = 56; goto _test_eof; 
	_test_eof57: cs = 57; goto _test_eof; 
	_test_eof58: cs = 58; goto _test_eof; 
	_test_eof59: cs = 59; goto _test_eof; 
	_test_eof60: cs = 60; goto _test_eof; 
	_test_eof61: cs = 61; goto _test_eof; 
	_test_eof62: cs = 62; goto _test_eof; 
	_test_eof63: cs = 63; goto _test_eof; 
	_test_eof64: cs = 64; goto _test_eof; 
	_test_eof65: cs = 65; goto _test_eof; 
	_test_eof66: cs = 66; goto _test_eof; 
	_test_eof67: cs = 67; goto _test_eof; 
	_test_eof68: cs = 68; goto _test_eof; 
	_test_eof69: cs = 69; goto _test_eof; 
	_test_eof70: cs = 70; goto _test_eof; 
	_test_eof71: cs = 71; goto _test_eof; 
	_test_eof72: cs = 72; goto _test_eof; 
	_test_eof73: cs = 73; goto _test_eof; 
	_test_eof74: cs = 74; goto _test_eof; 
	_test_eof75: cs = 75; goto _test_eof; 
	_test_eof76: cs = 76; goto _test_eof; 
	_test_eof77: cs = 77; goto _test_eof; 
	_test_eof78: cs = 78; goto _test_eof; 
	_test_eof79: cs = 79; goto _test_eof; 
	_test_eof80: cs = 80; goto _test_eof; 
	_test_eof81: cs = 81; goto _test_eof; 
	_test_eof82: cs = 82; goto _test_eof; 
	_test_eof83: cs = 83; goto _test_eof; 
	_test_eof84: cs = 84; goto _test_eof; 
	_test_eof85: cs = 85; goto _test_eof; 
	_test_eof86: cs = 86; goto _test_eof; 
	_test_eof87: cs = 87; goto _test_eof; 
	_test_eof88: cs = 88; goto _test_eof; 
	_test_eof89: cs = 89; goto _test_eof; 
	_test_eof90: cs = 90; goto _test_eof; 
	_test_eof91: cs = 91; goto _test_eof; 
	_test_eof92: cs = 92; goto _test_eof; 
	_test_eof93: cs = 93; goto _test_eof; 
	_test_eof94: cs = 94; goto _test_eof; 
	_test_eof95: cs = 95; goto _test_eof; 
	_test_eof96: cs = 96; goto _test_eof; 
	_test_eof97: cs = 97; goto _test_eof; 
	_test_eof98: cs = 98; goto _test_eof; 
	_test_eof99: cs = 99; goto _test_eof; 
	_test_eof100: cs = 100; goto _test_eof; 
	_test_eof101: cs = 101; goto _test_eof; 
	_test_eof102: cs = 102; goto _test_eof; 
	_test_eof103: cs = 103; goto _test_eof; 
	_test_eof104: cs = 104; goto _test_eof; 
	_test_eof105: cs = 105; goto _test_eof; 
	_test_eof106: cs = 106; goto _test_eof; 
	_test_eof107: cs = 107; goto _test_eof; 
	_test_eof108: cs = 108; goto _test_eof; 
	_test_eof109: cs = 109; goto _test_eof; 
	_test_eof110: cs = 110; goto _test_eof; 
	_test_eof111: cs = 111; goto _test_eof; 
	_test_eof112: cs = 112; goto _test_eof; 
	_test_eof113: cs = 113; goto _test_eof; 
	_test_eof114: cs = 114; goto _test_eof; 
	_test_eof115: cs = 115; goto _test_eof; 
	_test_eof116: cs = 116; goto _test_eof; 
	_test_eof117: cs = 117; goto _test_eof; 
	_test_eof118: cs = 118; goto _test_eof; 
	_test_eof119: cs = 119; goto _test_eof; 
	_test_eof120: cs = 120; goto _test_eof; 
	_test_eof121: cs = 121; goto _test_eof; 
	_test_eof122: cs = 122; goto _test_eof; 
	_test_eof123: cs = 123; goto _test_eof; 
	_test_eof124: cs = 124; goto _test_eof; 
	_test_eof125: cs = 125; goto _test_eof; 
	_test_eof126: cs = 126; goto _test_eof; 
	_test_eof127: cs = 127; goto _test_eof; 
	_test_eof128: cs = 128; goto _test_eof; 
	_test_eof129: cs = 129; goto _test_eof; 
	_test_eof130: cs = 130; goto _test_eof; 
	_test_eof131: cs = 131; goto _test_eof; 
	_test_eof132: cs = 132; goto _test_eof; 
	_test_eof133: cs = 133; goto _test_eof; 
	_test_eof134: cs = 134; goto _test_eof; 
	_test_eof135: cs = 135; goto _test_eof; 
	_test_eof136: cs = 136; goto _test_eof; 
	_test_eof137: cs = 137; goto _test_eof; 

	_test_eof: {}
	_out: {}
	}

#line 264 "src/admin.rl"


	tbuf_ltrim(fiber->rbuf, (void *)pe - (void *)fiber->rbuf->data);

	if (p != pe) {
		start(out);
		tbuf_append(out, unknown_command, strlen(unknown_command));
		end(out);
	}

	[conn coWrite: out->data :out->size];
}

/* {{{ Admin Service. *********************************************/

static SingleWorkerService *admin_service;

static void
admin_handler(ServiceConnection *conn)
{
	lua_State *L = lua_newthread(tarantool_L);
	int coro_ref = luaL_ref(tarantool_L, LUA_REGISTRYINDEX);
	/** Allow to interrupt/kill administrative connections. */
	fiber_setcancelstate(true);
	@try {
		for (;;) {
			admin_dispatch(conn, L);
			fiber_gc();
		}
	}
	@catch (SocketEOF *eof) {
		(void) eof;
	}
	@finally {
		luaL_unref(tarantool_L, LUA_REGISTRYINDEX, coro_ref);
		[conn close];
		[conn free];
	}
}

int
admin_init(void)
{
	@try {
		admin_service =
			[SingleWorkerService create: "admin"
						   :cfg.admin_port
						   :admin_handler];
		[admin_service start];
		return 0;
	}
	@catch (id e) {
		return -1;
	}
}

/* }}} */

/*
 * Local Variables:
 * mode: c
 * End:
 * vim: syntax=objc
 */
