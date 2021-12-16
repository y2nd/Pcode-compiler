/*
 *  Table des symboles.c
 *
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 */

#include "Table_des_symboles.h"
#include "Attribute.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/* The storage structure is implemented as a linked chain */

/* linked element def */

typedef struct elem {
	sid symbol_name;
	attribute symbol_value;
	struct elem * next;
} elem;

/* linked chain initial element */
static elem * storage=NULL;

/* get the symbol value of symb_id from the symbol table */
attribute get_symbol_value(sid symb_id) {
	elem * tracker=storage;

	/* look into the linked list for the symbol value */
	while (tracker) {
		if (tracker -> symbol_name == symb_id) return tracker -> symbol_value; 
		tracker = tracker -> next;
	}
    
	/* if not found does return NULL */
	return NULL;
};

/* set the value of symbol symb_id to value */
attribute set_symbol_value(sid symb_id,attribute value) {

	elem * tracker;
	
	/* look for the presence of symb_id in storage */
	
	// tracker = storage;
	// while (tracker) {
	// 	if (tracker -> symbol_name == symb_id) {
	// 		tracker -> symbol_value = value;
	// 		return tracker -> symbol_value;
	// 	}
	// 	tracker = tracker -> next;
	// }
	
	/* otherwise insert it at head of storage with proper value */
	
	tracker = malloc(sizeof(elem));
	tracker -> symbol_name = symb_id;
	tracker -> symbol_value = value;
	tracker -> next = storage;
	storage = tracker;
	return storage -> symbol_value;
}


// attribute get_nearest_symbol_value(sid symb_id, int block_num, struct block block_stack[]) {
// 	elem * tracker;
// 	tracker = storage;
// 	for(int i = block_num; i > 0; i++){
// 		while (tracker) {
// 			if (tracker -> symbol_name == symb_id && tracker -> symbol_value -> block_num == block_stack[i].block_num) {
// 					return tracker->symbol_value;
// 				}
// 		}
// 		tracker = tracker -> next;
// 	}
// 	return NULL;
// }


attribute var_is_declared(sid symb_id, int block_num) {
	elem * tracker;
	
	/* look for the presence of symb_id in storage */

	tracker = storage;
	while (tracker) {
		if (tracker -> symbol_name == symb_id && tracker -> symbol_value->block_num == block_num) {
			return tracker->symbol_value;
		}
		tracker = tracker -> next;
	}
	return NULL;
}

