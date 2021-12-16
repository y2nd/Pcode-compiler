#include "Attribute.h"

#include <stdlib.h>

attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  return r;
};

attribute attribute_plus(attribute a1, attribute a2) {
  attribute r;
  r = new_attribute();
  r->int_val = a1->int_val + a2->int_val;
  return r;
}

attribute attribute_moins(attribute a1, attribute a2) {
  attribute r;
  r = new_attribute();
  r->int_val = a1->int_val - a2->int_val;
  return r;
}

attribute attribute_star(attribute a1, attribute a2) {
  attribute r;
  r = new_attribute();
  r->int_val = a1->int_val * a2->int_val;
  return r;
}

attribute attribute_div(attribute a1, attribute a2) {
  attribute r;
  r = new_attribute();
  r->int_val = a1->int_val / a2->int_val;
  return r;
}


attribute attribute_minus(attribute a) {
  attribute r;
  r = new_attribute();
  r->int_val = -a->int_val;
  return r;
}

int att_is_equal(attribute a, attribute b) {
  return (a->block_num == b->block_num && a->name == b->name);
}
