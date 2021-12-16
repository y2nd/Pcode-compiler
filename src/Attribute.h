/*
 *  Attribute.h
 *
 *  Created by Janin on 10/2019
 *  Copyright 2018 LaBRI. All rights reserved.
 *
 *  Module for a clean handling of attibutes values
 *
 */

#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H

typedef enum {INT, FLOAT, FUNC} type;

struct ATTRIBUTE {
  char * name;
  int int_val;           // utilise' pour NUM et uniquement pour NUM
  type type_val;
  
  /* les autres attributs dont vous pourriez avoir besoin sont déclarés ici */
  int mp_offset; // l'offset par rapport à mp.
  int block_num; // le numéro du block contenant le variable.
  int arg_count; // utiliser pour les fonctions et seulement pour les fonctions. indique le nombre d'arguments d'une fonction.
};

typedef struct ATTRIBUTE * attribute;

attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

attribute attribute_plus(attribute a1, attribute a2);
attribute attribute_moins(attribute a1, attribute a2);
attribute attribute_star(attribute a1, attribute a2);
attribute attribute_div(attribute a1, attribute a2);
attribute attribute_minus(attribute a);

int att_is_equal(attribute a, attribute b);

#endif

