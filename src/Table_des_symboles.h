/*
 *  Table des symboles.h
 *
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 *  Associative array encoded as linked list of pair (symbol_name, symbol_value).
 *  To be used only with getter get_symbol_value and setter set_symbol_value.
 *
 *  Type attribute can be customized.
 *
 *  Symbol names must be valid sid from Table des chaines. 
 *
 */

#ifndef TABLE_DES_SYMBOLES_H
#define TABLE_DES_SYMBOLES_H

#include "Table_des_chaines.h"
#include "Attribute.h"

/* get the symbol value of symb_id from the symbol table, NULL if it fails */
attribute get_symbol_value(sid symb_id);

/* set the value of symbol symb_id to value, return NULL if it fails */
attribute set_symbol_value(sid symb_id, attribute value);

/* Check if a variable with the name symb_id is already declared within the block block_num */
attribute var_is_declared(sid symb_id, int block_num);

#endif
