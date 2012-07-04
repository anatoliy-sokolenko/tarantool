/*
 * Copyright (C) 2012 Mail.RU
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
/*
 * Copyright (c) 1993-1994 by Xerox Corporation.  All rights reserved.
 *
 * THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY EXPRESSED
 * OR IMPLIED.  ANY USE IS AT YOUR OWN RISK.
 *
 * Permission is hereby granted to use or copy this program
 * for any purpose,  provided the above notices are retained on all copies.
 * Permission to modify the code and to distribute modified code is granted,
 * provided the above notices are retained, and a notice that the code was
 * modified is included with the above copyright notice.
 *
 * Author: Hans-J. Boehm (boehm@parc.xerox.com)
 */
#ifndef CROPE_H_INCLUDED
#define CROPE_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>


/* ------------------------------------------------------------------------- *
 * Useful defines
 * ------------------------------------------------------------------------- */

#if !defined(MAX)
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#endif /* MAX */

#if !defined(MIN)
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif /* MIN */


/* ------------------------------------------------------------------- *
 * Ropes constants
 * ------------------------------------------------------------------- */

/**
 * Rope constants
 */
enum rope_consts {
	ROPE_DEPTH_MAX = 45,
};

/**
 * Rope node types
 */
enum rope_node_type {
	/* rope leaf node */
	ROPE_LEAF   = 0,
	/* rope concatenation node */
	ROPE_CONCAT = 1,
};


/* ------------------------------------------------------------------- *
 * Rope macros
 * ------------------------------------------------------------------- */

#define crope_decl(name)						\
									\
	/* --------------------------------------------------------- *	\
	 * Ropes structures declaration					\
	 * ----------------------------------------------------------*/	\
									\
	/**								\
	 * Rope base node.						\
	 */								\
	struct rope_##name##_node {					\
		/** Node type. */					\
		enum rope_node_type type;				\
	};								\
									\
	/**								\
	 * Rope.							\
	 */								\
	struct rope_##name {						\
		/** Root of the rope. */				\
		struct rope_##name##_node *root;			\
		/** Rope size. */					\
		size_t size;						\
	};								\
									\
	/**								\
	 * Rope concatenation node.					\
	 */								\
	struct rope_##name##_concat {					\
		/** Parent structure. */				\
		struct rope_##name##_node base;				\
		/** Size of the left sub-tree. */			\
		size_t weight;						\
		/** Depth of the rope. */				\
		uint8_t depth;						\
		/** Left child. */					\
		struct rope_##name##_node *left;			\
		/** Right child. */					\
		struct rope_##name##_node *right;			\
	};								\
									\
	/**								\
	 * Rope leaf node.						\
	 */								\
	struct rope_##name##_leaf {					\
		/** Parent structure. */				\
		struct rope_##name##_node base;				\
		/**							\
		 * Number element in the sequence the leaf contains.	\
		 */							\
		size_t size;						\
		/** The sequence the leaf contains. */			\
		const char *data;					\
	};								\
									\
									\
	/**								\
	 * Rope forest element						\
	 */								\
	struct rope_##name##_forest {					\
		/** A pointer to the rope the forest element has. */	\
		struct rope_##name##_node *tree;			\
		/** Actual forest element length. */			\
		size_t size;						\
	};								\
									\
	/**								\
	 * Rope iterator declaration					\
	 */								\
	struct rope_##name##_iter {					\
		/** Iterator reaches the end of the sequence. */	\
		bool is_end;						\
		/** the node the iterator pointed. */			\
		struct rope_##name##_node *ptr;				\
		/** Current depth. */					\
		int depth;						\
		/** Node stack. */					\
		struct rope_##name##_node *stack[ROPE_DEPTH_MAX];	\
	};								\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Ropes functions declaration					\
	 * ----------------------------------------------------------*/	\
									\
	/**								\
	 * Create a new rope, which contains a data.			\
	 * @param data is a sequence.					\
	 * @param size is number element in the sequence.		\
	 * @param memm is a rope memory management.			\
	 * @param sequence is a sequence.				\
	 * @return the rope instance or NULL if error was happened.	\
	 */								\
	struct rope_##name *						\
	rope_##name##_new(const char *data, size_t size);		\
									\
	/**								\
	 * Delete a rope.						\
	 * @param rope is a rope.					\
	 */								\
	void								\
	rope_##name##_delete(struct rope_##name *rope);			\
									\
	/**								\
	 * Append a sequence data to a rope.				\
	 * @param rope is a rope.					\
	 * @param data is a appending sequence.				\
	 * @param size is number element in the sequence.		\
	 */								\
	void								\
	rope_##name##_append(struct rope_##name *rope,			\
			     const char *data,				\
			     size_t size);				\
									\
	/**								\
	 * Prepend a sequence data to the rope.				\
	 * @param rope is a rope.					\
	 * @param data is a prepending sequence.			\
	 * @param size is number element in the sequence.		\
	 */								\
	void								\
	rope_##name##_prepend(struct rope_##name *rope,			\
			      const char *data,				\
			      size_t size);				\
									\
	/**								\
	 * Insert a sequence to the rope to pos position.		\
	 * @param rope is a rope.					\
	 * @param pos is a inserting position.				\
	 * @param data is a inserting sequence.				\
	 * @param size is number element in the inserting sequence.	\
	 */								\
	void								\
	rope_##name##_insert(struct rope_##name *rope,			\
			     size_t pos,				\
			     const char *data,				\
			     size_t size);				\
									\
	/**								\
	 * Remove size element from the rope from pos position.		\
	 * @param rope is a rope.					\
	 * @param pos is a removing position.				\
	 * @param size is number of removing elements.			\
	 */								\
	void								\
	rope_##name##_remove(struct rope_##name *rope,			\
			     size_t pos,				\
			     size_t size);				\
									\
	/**								\
	 * Print all nodes of a rope to stdout.				\
	 * @param rope is a rope.					\
	 */								\
	void								\
	rope_##name##_print_tree(const char *name,			\
				 struct rope_##name *rope);		\
									\
	/**								\
	 * Print a sequence which a rope contains.			\
	 * @param rope is a rope.					\
	 */								\
	void								\
	rope_##name##_print_sequence(struct rope_##name *root);		\
									\
	/**								\
	 * Create a new iterator.					\
	 * @param rope is a rope.					\
	 * @return the initialized iterator.				\
	 */								\
	struct rope_##name##_iter *					\
	rope_##name##_iter_new(struct rope_##name *rope);		\
									\
	/**								\
	 * Delete iterator.						\
	 * @param iter is a deleting iterator.				\
	 */								\
	void								\
	rope_##name##_iter_delete(struct rope_##name##_iter *iter);	\
									\
	/**								\
	 * Move iterator to the next leaf.				\
	 * @param iter is a iterator.					\
	 */								\
	void								\
	rope_##name##_iter_next(struct rope_##name##_iter *iter);	\


#define crope_definition(name,						\
			 seq_getn,					\
			 seq_print,					\
			 mem_alloc,					\
			 mem_free)					\
									\
	/* --------------------------------------------------------- *	\
	 * Rope node local functions declaration			\
	 * ----------------------------------------------------------*/	\
									\
	/**								\
	 * Create a new leaf node.					\
	 * @param data is a contained sequence.				\
	 * @param size is a number element in the sequence.		\
	 * @return a rope or NULL if error happened.			\
	 */								\
	static struct rope_##name##_node *				\
	node_##name##_leaf(const char *data,				\
			   size_t size);				\
									\
	/**								\
	 * Create a new concatenation node.				\
	 * @param data is a contained sequence.				\
	 * @param size is a number element in the sequence.		\
	 * @return a rope node.						\
	 */								\
	static struct rope_##name##_node *				\
	node_##name##_concat(struct rope_##name##_node *left,		\
			     struct rope_##name##_node *right);		\
									\
									\
	/**								\
	 * Split a rope on two parts. The first contains symbols	\
	 * form 0..n and the						\
	 * second contains symbols from n+1..rope_size(root).		\
	 * @param tree is a split tree.					\
	 * @param tree_size is a split tree size.			\
	 * @param size is a number element in the sequence.		\
	 * @return a split tail rope.					\
	 */								\
	static struct rope_##name##_node *				\
	node_##name##_split(struct rope_##name##_node *tree,		\
			    size_t tree_size,				\
			    size_t size);				\
									\
	/**								\
	 * Delete a rope node.						\
	 * @param node is a deleted rope node.				\
	 * @param alloc is a rope allocator.				\
	 */								\
	static void							\
	node_##name##_delete(struct rope_##name##_node *node);		\
									\
	/**								\
	 * Get rope size.						\
	 * @param node is a rope node.					\
	 * @return depth of the rope.					\
	 */								\
	static inline size_t						\
	node_##name##_size(struct rope_##name##_node *node);		\
									\
	/**								\
	 * Get rope depth.						\
	 * @param node is a rope node.					\
	 * @return depth of the rope.					\
	 */								\
	static inline size_t						\
	node_##name##_depth(struct rope_##name##_node *node);		\
									\
	/**								\
	 * Check, is a rope tree balanced.				\
	 * @param tree is a rope tree.					\
	 * @return true if rope is balanced else false is returned.	\
	 */								\
	static inline bool						\
	node_##name##_is_balanced(struct rope_##name##_node *tree);	\
									\
	/**								\
	 * Print rope nodes.						\
	 * @param rope is rope node.					\
	 * @param prefix is a printed prefix.				\
	 * @param is_tail is a rope last child which has it parent.	\
	 */								\
	static void							\
	node_##name##_print(struct rope_##name##_node *rope,		\
			    const char *prefix,				\
			    bool is_tail);				\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Rope local functions declaration				\
	 * ----------------------------------------------------------*/	\
									\
	/**								\
	 * Check, is a rope balanced.					\
	 * @param rope is a rope.					\
	 */								\
	static inline bool						\
	rope_##name##_is_balanced(struct rope_##name *rope);		\
									\
	/**								\
	 * Re-balance a rope.						\
	 * @param rope is a rope.					\
	 * @return 0 if rope was rebalanced else error is returned.	\
	 */								\
	static void							\
	rope_##name##_rebalance(struct rope_##name *rope);		\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Forest local functions declaration				\
	 * ----------------------------------------------------------*/	\
									\
	/**								\
	 * Insert a rope tree to a forest.				\
	 * @param forest is a forest.					\
	 * @param tree is a rope tree.					\
	 * @param tree_size is a rope tree length.			\
	 */								\
	static void							\
	forest_##name##_insert(struct rope_##name##_forest *forest,	\
			       struct rope_##name##_node *tree,		\
			       size_t tree_size);			\
									\
	/**								\
	 * Build a forest of balanced trees from a unbalanced rope.	\
	 * @param forest is a forest.					\
	 * @param tree is a rope tree.					\
	 * @param tree_size is a rope tree length.			\
	 */								\
	static void							\
	forest_##name##_build(struct rope_##name##_forest *forest,	\
			      struct rope_##name##_node *tree,		\
			      size_t tree_size);			\
									\
	/**								\
	 * Merge a forest of balanced trees to a balanced rope.		\
	 * @param forest is a forest.					\
	 * @param expected_length is a expected rope length.		\
	 * @return balanced tree, which contains all trees from forest.	\
	 */								\
	static struct rope_##name##_node *				\
	forest_##name##_concat(struct rope_##name##_forest *forest,	\
			       size_t expected_length);			\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Rope iterator local functions declaration			\
	 * ----------------------------------------------------------*/	\
									\
	/**								\
	 * Change iterator node to the rope and save old value in	\
	 * the iterator stack.						\
	 * @param iter is an iterator.					\
	 * @param node is a node which setting to the iterator.		\
	 */								\
	static inline void						\
	rope_##name##_iter_push(struct rope_##name##_iter *iter,	\
				struct rope_##name##_node *node);	\
									\
	/**								\
	 * Get node from the stack and set it as iterator value.	\
	 * @param iter is an iterator.					\
	 * @return true will be returned if operation is success	\
	 *         else false will be returned.				\
	 */								\
	static inline bool						\
	rope_##name##_iter_pop(struct rope_##name##_iter *iter);	\
									\
	/**								\
	 * Get node from the stack.					\
	 * @param iter is an iterator.					\
	 * @return the node from the stack top.				\
	 */								\
	static inline struct rope_##name##_node *			\
	rope_##name##_iter_top(struct rope_##name##_iter *iter);	\
									\
	/**								\
	 * Move iterator to the not visited node.			\
	 * @param iter is an iterator.					\
	 */								\
	static inline void						\
	rope_##name##_iter_goto_right(struct rope_##name##_iter *iter);	\
									\
	/**								\
	 * Move iterator to the leftest leaf of the rope.		\
	 * @param iter is an iterator.					\
	 */								\
	static inline void						\
	rope_##name##_iter_down_to_leaf(struct rope_##name##_iter *iter); \
									\
									\
	/* --------------------------------------------------------- *	\
	 * Ropes functions definition					\
	 * ----------------------------------------------------------*/	\
									\
	struct rope_##name *						\
	rope_##name##_new(const char *data,				\
			  size_t size)					\
	{								\
		struct rope_##name *rope = malloc(sizeof(struct rope_##name)); \
		rope->root = node_##name##_leaf(data, size);		\
		rope->size = size;					\
									\
		return rope;						\
	}								\
									\
	void								\
	rope_##name##_delete(struct rope_##name *rope)			\
	{								\
		if (rope->root)						\
			node_##name##_delete(rope->root);		\
		free(rope);						\
	}								\
									\
									\
	void								\
	rope_##name##_append(struct rope_##name *rope,			\
			     const char *data,				\
			     size_t size)				\
	{								\
		struct rope_##name##_node *tail =			\
			node_##name##_leaf(data, size);			\
		rope->root = node_##name##_concat(rope->root, tail);	\
		rope->size += size;					\
		if (!rope_##name##_is_balanced(rope))			\
			rope_##name##_rebalance(rope);			\
	}								\
									\
	void								\
	rope_##name##_prepend(struct rope_##name *rope,			\
		     const char *data,					\
		     size_t size)					\
	{								\
		struct rope_##name##_node *head =			\
			node_##name##_leaf(data, size);			\
		rope->root = node_##name##_concat(head, rope->root);	\
		rope->size += size;					\
		if (!rope_##name##_is_balanced(rope))			\
			rope_##name##_rebalance(rope);			\
	}								\
									\
	void								\
	rope_##name##_insert(struct rope_##name *rope,			\
			     size_t pos,				\
			     const char *data,				\
			     size_t size)				\
	{								\
		if (pos > rope->size) {					\
			rope_##name##_append(rope, data, size);		\
		} else if (pos == 0) {					\
			rope_##name##_prepend(rope, data, size);	\
		} else {						\
									\
			struct rope_##name##_node *tail =		\
				node_##name##_split(rope->root,		\
						    rope->size,		\
						    pos);		\
			struct rope_##name##_node *inner =		\
				node_##name##_leaf(data, size);		\
									\
			rope->root = node_##name##_concat(rope->root,	\
							  inner);	\
			rope->root = node_##name##_concat(rope->root,	\
							  tail);	\
			rope->size += size;				\
		}							\
	}								\
									\
	void								\
	rope_##name##_remove(struct rope_##name *rope,			\
			     size_t pos,				\
			     size_t size)				\
	{								\
		size = MIN(size, rope->size - pos);			\
									\
		if (pos == 0) {						\
			/* Removing the beginning of the rope. */	\
			struct rope_##name##_node *new_root =		\
				node_##name##_split(rope->root,		\
						    rope->size,		\
						    size);		\
			node_##name##_delete(rope->root);		\
			rope->root = new_root;				\
			rope->size = rope->size - size;			\
		} else if (rope->size - pos <= size) {			\
			/* Removing the ending of the rope */		\
			struct rope_##name##_node *tail =		\
				node_##name##_split(rope->root,		\
						    rope->size,		\
						    pos);		\
			rope->size = pos;				\
			node_##name##_delete(tail);			\
		} else {						\
			struct rope_##name##_node *tail =		\
				node_##name##_split(rope->root,		\
						    rope->size,		\
						    pos + size);	\
			struct rope_##name##_node *inner =		\
				node_##name##_split(rope->root,		\
						    rope->size,		\
						    pos);		\
			rope->root = node_##name##_concat(rope->root,	\
							  tail);	\
			rope->size -= size;				\
			node_##name##_delete(inner);			\
		}							\
	}								\
									\
	void								\
	rope_##name##_print_tree(const char *name,			\
				 struct rope_##name *rope)		\
	{								\
		printf("%s (size = %zu, balance = %i) = '",		\
		       name, rope->size,				\
		       rope_##name##_is_balanced(rope));		\
		rope_##name##_print_sequence(rope);			\
		printf("'\n");						\
		node_##name##_print(rope->root, "", true);		\
	}								\
									\
	void								\
	rope_##name##_print_sequence(struct rope_##name *rope)		\
	{								\
		struct rope_##name##_iter *iter =			\
			rope_##name##_iter_new(rope);			\
		if (!iter)						\
			return;						\
									\
		while (!iter->is_end) {					\
			struct rope_##name##_leaf *leaf =		\
				(struct rope_##name##_leaf *) iter->ptr; \
			seq_print(leaf->data, leaf->size);		\
 			rope_##name##_iter_next(iter);			\
		}							\
									\
		rope_##name##_iter_delete(iter);			\
	}								\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Ropes iterators functions declaration			\
	 * ----------------------------------------------------------*/	\
									\
	struct rope_##name##_iter *					\
	rope_##name##_iter_new(struct rope_##name *rope)		\
	{								\
		struct rope_##name##_iter *iter =			\
			malloc(sizeof(struct rope_##name##_iter));	\
		iter->ptr = rope->root;					\
		iter->depth = 0;					\
		iter->is_end = false;					\
									\
		rope_##name##_iter_down_to_leaf(iter);			\
		return iter;						\
	}								\
									\
	void								\
	rope_##name##_iter_delete(struct rope_##name##_iter *iter)	\
	{								\
		free(iter);						\
	}								\
									\
	void								\
	rope_##name##_iter_next(struct rope_##name##_iter *iter)	\
	{								\
		rope_##name##_iter_goto_right(iter);			\
		if (!iter->is_end)					\
			rope_##name##_iter_down_to_leaf(iter);		\
	}								\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Rope node local functions declaration			\
	 * ----------------------------------------------------------*/	\
									\
	static struct rope_##name##_node *				\
	node_##name##_leaf(const char *data,				\
			   size_t size)					\
	{								\
		/* allocating a new leaf */				\
		struct rope_##name##_leaf *leaf = malloc(		\
			sizeof(struct rope_##name##_leaf));		\
		memset(leaf, 0, sizeof(struct rope_##name##_leaf));	\
									\
		/* initializing the leaf */				\
		leaf->base.type = ROPE_LEAF;				\
		leaf->size = size;					\
		leaf->data = data;					\
									\
		return (struct rope_##name##_node *) leaf;		\
	}								\
									\
	static struct rope_##name##_node *				\
	node_##name##_concat(struct rope_##name##_node *left,		\
			     struct rope_##name##_node *right)		\
	{								\
		if (!left || !right) {					\
			if (left)					\
				return left;				\
			else						\
				return right;				\
		}							\
									\
		/* creating concatenation node */			\
		struct rope_##name##_concat *concat = malloc(		\
			sizeof(struct rope_##name##_concat));		\
		memset(concat, 0, sizeof(struct rope_##name##_concat));	\
									\
		/* initializing concatenation node */			\
		concat->base.type = ROPE_CONCAT;			\
		concat->depth = MAX(node_##name##_depth(left),		\
				    node_##name##_depth(right)) + 1;	\
		concat->weight = node_##name##_size(left);		\
		concat->left = left;					\
		concat->right = right;					\
									\
		return (struct rope_##name##_node *) concat;		\
	}								\
									\
	static struct rope_##name##_node *				\
	node_##name##_split(struct rope_##name##_node *tree,		\
			    size_t tree_size,				\
			    size_t size)				\
	{								\
		if (size >= tree_size)					\
			return NULL;					\
									\
		struct rope_##name##_node *curr = tree;			\
		struct rope_##name##_node *tail = NULL;			\
		size_t curr_size = tree_size;				\
		size_t curr_trim = curr_size - size;			\
									\
		while (curr_trim > 0 && curr->type != ROPE_LEAF) {	\
			struct rope_##name##_concat *concat =		\
				(struct rope_##name##_concat *) curr;	\
			if (curr_size - concat->weight <= curr_trim) {	\
				/*					\
				 * The right less or equal trim size,	\
				 * so it should be cut for the rope.	\
				 */					\
				tail = node_##name##_concat(		\
					concat->right, tail);		\
				/* updating trim */			\
				curr_trim = curr_trim - curr_size +	\
					concat->weight;			\
				/* updating the rope */			\
				concat->right = NULL;			\
				concat->depth =				\
					node_##name##_depth(concat->left) \
					+ 1;				\
									\
				/* moving to the left sub tree */	\
				curr_size = concat->weight;		\
									\
				/*					\
				 * updating current node weight,	\
				 because we should cut from the left	\
				 sub tree curr_trim elements		\
				*/					\
				concat->weight -= curr_trim;		\
				curr = concat->left;			\
			} else {					\
				/*					\
				 * The right sub tree greater than trim \
				 * size, so it contain sub tree which	\
				 should be cut from the rope		\
				*/					\
				curr_size = curr_size - concat->weight;	\
				curr = concat->right;			\
			}						\
		}							\
									\
		if (curr_trim) {					\
			struct rope_##name##_leaf *leaf =		\
				(struct rope_##name##_leaf *) curr;	\
			/*						\
			 * we stay in the leaf node and we need to cut  \
			 * some elements from the rope, so we should	\
			 * split the leaf on two parts.			\
			 */						\
			/* reducing leaf size */			\
			leaf->size -= curr_trim;			\
			/*						\
			 * creating new rope node which contains tail	\
			 * of the string				\
			 */						\
			struct rope_##name##_node *r = node_##name##_leaf( \
				seq_getn(leaf->data, leaf->size),	\
				curr_trim);				\
			/*						\
			 * concatenating the rope which was cut from	\
			 * the leaf and current tail.			\
			 */						\
			tail = node_##name##_concat(r, tail);		\
		}							\
		return tail;						\
	}								\
									\
	static void							\
	node_##name##_delete(struct rope_##name##_node *node)		\
	{								\
		/*							\
		 * We should delete left and right sub-trees if it is	\
		 * concatenation  node.					\
		 */							\
		if (node->type == ROPE_CONCAT) {			\
			struct rope_##name##_concat *concat =		\
				(struct rope_##name##_concat *) node;	\
			/*						\
			 * releasing sub-trees for concatenation node.	\
			 */						\
			if (concat->left)				\
				/* deleting left sub tree. */		\
				node_##name##_delete(concat->left);	\
			if (concat->right)				\
				/* deleting right sub tree. */		\
				node_##name##_delete(concat->right);	\
		}							\
		/* releasing node structure. */				\
		free(node);						\
	}								\
									\
	static inline size_t						\
	node_##name##_size(struct rope_##name##_node *node)		\
	{								\
		size_t size = 0;					\
									\
		/* Traversing from the root to the right leaf. */	\
		while (node && node->type != ROPE_LEAF) {		\
			struct rope_##name##_concat *concat =		\
				(struct rope_##name##_concat *) node;	\
			/* Adding the left sub-tree size. */		\
			size += concat->weight;				\
			/* Moving to the right sub-tree. */		\
			node = concat->right;				\
		}							\
									\
		/* Adding the right leaf size, if it exists. */		\
		if (node) {						\
			struct rope_##name##_leaf *leaf =		\
				(struct rope_##name##_leaf *) node;	\
			size += leaf->size;				\
		}							\
									\
		return size;						\
	}								\
									\
	static inline size_t						\
	node_##name##_depth(struct rope_##name##_node *node)		\
	{								\
		if (node->type != ROPE_LEAF) {				\
			struct rope_##name##_concat *concat =		\
				(struct rope_##name##_concat *) node;	\
			return concat->depth;				\
		} else {						\
			/* any leaf has 0 depth. */			\
			return 0;					\
		}							\
	}								\
									\
	/**								\
	 * Minimal length of the balanced rope which it should has.	\
	 */								\
	static const size_t rope_##name##_size_min[ROPE_DEPTH_MAX + 1] = { \
		1u, 2u, 3u, 5u, 8u, 13u, 21u, 34u, 55u, 89u, 144u,	\
		233u, 377u, 610u, 987u, 1597u, 2584u, 4181u, 6765u,	\
		10946u, 17711u, 28657u, 46368u, 75025u, 121393u,	\
		196418u, 317811u, 514229u, 832040u, 1346269u,		\
		2178309u, 3524578u, 5702887u, 9227465u, 14930352u,	\
		24157817u, 39088169u, 63245986u, 102334155u,		\
		165580141u, 267914296u, 433494437u, 701408733u,		\
		1134903170u, 1836311903u, 2971215073u			\
	};								\
									\
	static inline bool						\
	node_##name##_is_balanced(struct rope_##name##_node *tree)	\
	{								\
		/*							\
		 * A rope is balanced if has depth less or equal than	\
		 * Fib(n), where n is size of the sequence.		\
		 */							\
		return node_##name##_size(tree)				\
			>= rope_##name##_size_min[node_##name##_depth(tree)]; \
	}								\
									\
	static void							\
	node_##name##_print(struct rope_##name##_node *node,		\
			    const char *prefix,				\
			    bool is_tail)				\
	{								\
		/* It's used only for _DEBUG_. */			\
		const char *midl_conn = "├── ";				\
		const char *tail_conn = "└── ";				\
									\
		const char *conn = midl_conn;				\
		if (is_tail)						\
			conn = tail_conn;				\
									\
		printf("%s%s", prefix, conn);				\
									\
		if (!node) {						\
			printf("nil\n");				\
			return;						\
		}							\
									\
		if (node->type == ROPE_LEAF) {				\
			struct rope_##name##_leaf *leaf =		\
				(struct rope_##name##_leaf *) node;	\
			printf("{ len = %zu, data = '", leaf->size);	\
			seq_print(leaf->data, leaf->size);		\
			printf("'}\n");					\
			return;						\
		}							\
									\
		struct rope_##name##_concat *concat =			\
			(struct rope_##name##_concat *) node;		\
		printf("{ depth = %zu, weight = %zu }\n",		\
		       node_##name##_depth(node),			\
		       concat->weight);					\
									\
		const char *midl_padd = "│   ";				\
		const char *tail_padd = "    ";				\
									\
		size_t child_prefix_len = strlen(prefix)		\
			+ MAX(sizeof(midl_padd), sizeof(tail_padd));	\
			char *child_prefix = malloc(child_prefix_len);	\
									\
			const char *padd = midl_padd;			\
			if (is_tail)					\
				padd = tail_padd;			\
									\
			sprintf(child_prefix, "%s%s", prefix, padd);	\
									\
			node_##name##_print(concat->left,		\
					    child_prefix,		\
					    false);			\
			node_##name##_print(concat->right,		\
					    child_prefix,		\
					    true);			\
									\
			free(child_prefix);				\
	}								\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Rope local functions definition				\
	 * ----------------------------------------------------------*/	\
									\
	static inline bool						\
	rope_##name##_is_balanced(struct rope_##name *rope)		\
	{								\
		/*							\
		 * A rope is balanced if has depth less or equal	\
		 * than Fib(n), where n is size of the sequence.	\
		 */							\
		return rope->size >=					\
			rope_##name##_size_min[node_##name##_depth(rope->root)]; \
	}								\
									\
	static void							\
	rope_##name##_rebalance(struct rope_##name *rope)		\
	{								\
		size_t forest_size = sizeof(struct rope_##name##_forest) * \
			ROPE_DEPTH_MAX;					\
		struct rope_##name##_forest *forest = malloc(forest_size); \
		memset(forest, 0, forest_size);				\
									\
		/* building a forest of balancing tree from old rope */	\
		forest_##name##_build(forest, rope->root, rope->size);	\
		/*							\
		 * Concatenating the forest to the one tree. The	\
		 * concatenation node is new root. Size of the rope	\
		 * doesn't change.					\
		 */							\
		rope->root = forest_##name##_concat(forest, rope->size); \
									\
		free(forest);						\
	}								\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Forest local functions definition				\
	 * ----------------------------------------------------------*/	\
									\
	static void							\
	forest_##name##_insert(struct rope_##name##_forest *forest,	\
			       struct rope_##name##_node *tree,		\
			       size_t tree_size)			\
	{								\
		struct rope_##name##_node *concat = NULL;		\
		size_t concat_size = 0;					\
									\
		int i = 0;						\
		/*							\
		 * Looking for the place in the forest, where we can	\
		 * insert the tree					\
		 */							\
		while (tree_size > rope_##name##_size_min[i + 1]) {	\
			if (forest[i].tree) {				\
				/*					\
				 * Concatenate to one all ropes which	\
				 * we meet.				\
				 */					\
				concat = node_##name##_concat(forest[i].tree, \
							      concat);	\
				concat_size += forest[i].size;		\
				/* clean-up */				\
				forest[i].tree = NULL;			\
				forest[i].size = 0;			\
			}						\
			++i;						\
		}							\
									\
		/* Concatenate summary rope with inserting rope. */	\
		concat = node_##name##_concat(concat, tree);		\
		concat_size += tree_size;				\
									\
		/*							\
		 * Looking for the place in the forest, where we can	\
		 * insert the concatenate tree.				\
		 */							\
		while (concat_size >= rope_##name##_size_min[i]) {	\
			if (forest[i].tree) {				\
				concat = node_##name##_concat(forest[i].tree, \
							      concat);	\
				concat_size += forest[i].size;		\
				forest[i].tree = NULL;			\
				forest[i].size = 0;			\
			}						\
			++i;						\
		}							\
									\
		forest[i - 1].tree = concat;				\
		forest[i - 1].size = concat_size;			\
	}								\
									\
	static void							\
	forest_##name##_build(struct rope_##name##_forest *forest,	\
			      struct rope_##name##_node *tree,		\
			      size_t tree_size)				\
	{								\
		if (!node_##name##_is_balanced(tree)) {			\
			struct rope_##name##_concat *concat =		\
				(struct rope_##name##_concat *) tree;	\
			/*						\
			 * The concatenation node isn't balanced,	\
			 * checking the node child.			\
			 */						\
			/* going to left sub-tree */			\
			if (concat->left)				\
				forest_##name##_build(forest,		\
						      concat->left,	\
						      concat->weight);	\
			/* going to right sub-tree */			\
			if (concat->right)				\
				forest_##name##_build(forest,		\
						      concat->right,	\
						      tree_size - concat->weight); \
			/*						\
			 * Deleting concatenation node, because it	\
			 isn't needed anymore.				\
			*/						\
			concat->left = NULL;				\
			concat->right = NULL;				\
			node_##name##_delete(tree);			\
		} else {						\
			/*						\
			 * The tree is already balanced. In fact, any	\
			 * leaf node is always balanced.		\
			 */						\
			forest_##name##_insert(forest, tree, tree_size); \
		}							\
	}								\
									\
	static struct rope_##name##_node *				\
	forest_##name##_concat(struct rope_##name##_forest *forest,	\
			       size_t expected_size)			\
	{								\
		struct rope_##name##_node *concat = NULL;		\
		size_t concat_size = 0;					\
									\
		for (int i = 0; concat_size < expected_size; ++i) {	\
			if (forest[i].tree) {				\
				concat = node_##name##_concat(		\
					forest[i].tree, concat);	\
				concat_size += forest[i].size;		\
			}						\
		}							\
									\
		return concat;						\
	}								\
									\
									\
	/* --------------------------------------------------------- *	\
	 * Rope iterator local functions definition			\
	 * ----------------------------------------------------------*/	\
									\
	static inline void						\
	rope_##name##_iter_push(struct rope_##name##_iter *iter,	\
				struct rope_##name##_node *node)	\
	{								\
		iter->stack[iter->depth] = iter->ptr;			\
		++iter->depth;						\
									\
		iter->ptr = node;					\
	}								\
									\
	static inline bool						\
	rope_##name##_iter_pop(struct rope_##name##_iter *iter)		\
	{								\
		if (iter->depth <= 0)					\
			return false;					\
									\
		--iter->depth;						\
		iter->ptr = iter->stack[iter->depth];			\
		return true;						\
	}								\
									\
	static inline struct rope_##name##_node *			\
	rope_##name##_iter_top(struct rope_##name##_iter *iter)		\
	{								\
		return iter->stack[iter->depth];			\
	}								\
									\
	static inline void						\
	rope_##name##_iter_goto_right(struct rope_##name##_iter *iter)	\
	{								\
		while (true) {						\
			struct rope_##name##_node *child = iter->ptr;	\
			if (!rope_##name##_iter_pop(iter)) {		\
				/* We back to rope's root, */		\
				iter->is_end = true;			\
				return;					\
			}						\
									\
			struct rope_##name##_concat *concat =		\
				(struct rope_##name##_concat *) iter->ptr; \
			if (child == concat->left && concat->right) {	\
				rope_##name##_iter_push(iter,		\
							concat->right);	\
				return;					\
			}						\
		}							\
	}								\
									\
	static inline void						\
	rope_##name##_iter_down_to_leaf(struct rope_##name##_iter *iter) \
	{								\
		while(iter->ptr->type != ROPE_LEAF) {			\
			struct rope_##name##_concat *concat =		\
				(struct rope_##name##_concat *) iter->ptr; \
			if (concat->left)				\
				rope_##name##_iter_push(iter,		\
							concat->left);	\
			else						\
				rope_##name##_iter_push(iter,		\
							concat->right); \
		}							\
	}								\

#endif /* CROPE_H_INCLUDED */
