%{

#include "Table_des_symboles.h"
#include "Attribute.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// le nombre maximal de blocks imbriqués.
#define MAX_NESTED_BLOCKS 100 

extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
}

FILE * filec;

int new_label() {
  static int label_counter = 0; 
  return label_counter++;
}

struct block {
  int block_num;
  int offset;
};

struct block block_stack[MAX_NESTED_BLOCKS];
int block_num = 1;
int block_pointer = 0; // un pointeur sur le block courant.

void enter_block() {
  struct block new_block = {.block_num = block_num, .offset = 0};
  block_stack[block_pointer] = new_block;
  block_num++;
  block_pointer++;
}

int current_block() {
  return block_pointer-1;
}

void exit_block() {
  block_pointer--;
}

int make_mp_offset() {
  return block_stack[current_block()].offset++;
}

attribute get_nearest_symbol(sid symb_id) {
  attribute att;
  for(int i = current_block(); i >= 0; i--) {
    att = var_is_declared(symb_id, block_stack[i].block_num);
    if(att != NULL) {
      return att;
    }
  }
  return NULL;
}

int is_in_main = 0; // a flag indicating the main function.
int arg_counter = 0; // utility to count the number of arguments of a function.

char* get_string(attribute x) {
    int block_pointer = current_block();
    char * s1 = "stack["; 
    char * s2 = "-1]"; 
    char * s3 = "mp"; 
    char s4[10];
    sprintf(s4, "+%d", x->mp_offset);
    char * res = malloc(100 * sizeof(char));
    char * p = res;
    
    while(x->block_num != block_stack[block_pointer].block_num){
        strcpy(p, s1);
        p += 6;
        block_pointer--;
    }
    strcpy(p, s3); p += 2;
    block_pointer = current_block();
    while(x->block_num != block_stack[block_pointer].block_num){
        strcpy(p, s2);
        p += 3;
        block_pointer--;
    }
    strcpy(p, s4); p += strlen(s4);
    *p = '\0';
    return res;
}

%}

%union { 
	struct ATTRIBUTE * att;
  int num;
}

%token <att> NUM
%token TINT
%token <att> ID
%token AO AF PO PF PV VIR 
%token RETURN VOID EQ
%token <att> IF ELSE WHILE

%token <att> AND OR NOT DIFF EQUAL SUP INF SUPEQ INFEQ
%token PLUS MOINS STAR DIV
%token DOT ARR

%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DIFF EQUAL SUP INF SUPEQ INFEQ       // higher priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE


%start prog  

// liste de tous les non terminaux dont vous voulez manipuler l'attribut
%type <att> exp  typename  type 
%type <num> while while_cond  
%type <num> cond if bool_cond inst elsop else

%%

prog : func_list               {;}
;

func_list : func_list fun      {;}
| fun                          {;}
;


// I. Functions
// ajouter la regle fun-type -> type 
fun : type fun_head fun_body        {}
;

fun_head : fun_id PO PF           {
                                    fprintf(filec, ") {\n");
                                  } 
| fun_id PO params PF             {
                                    fprintf(filec, ") {\n");
                                    get_symbol_value($<att>1->name)->arg_count = arg_counter;
                                    arg_counter=0;
                                  }
;

fun_id: ID                      { 
  
                                  enter_block();
                                  if (strcmp($1->name, "main") != 0) {
                                    if(get_symbol_value($1->name) != NULL){
                                      fprintf(stderr, "%s is already declared!\n" ,$1->name);
                                    } 
                                    else {
                                    attribute f = new_attribute();
                                    f->type_val = FUNC;
                                    f->name = $1->name;
                                    set_symbol_value(f->name, f);
                                    fprintf(filec, "void %s(", $1->name);
                                    $<att>$ = f;
                                    }
                                    is_in_main = 0;
                                  }
                                  else {
                                    is_in_main = 1;
                                    fprintf(filec, "%s %s(", $<att>0->name, $1->name);
                                  }
                                }

params: arg params             {}
| type ID                      {
                                attribute arg = new_attribute();
                                arg->name = $2->name;
                                arg->type_val = $1->type_val;
                                arg->mp_offset = make_mp_offset();
                                arg->block_num = block_stack[current_block()].block_num;
                                // fprintf(filec, "%s %s", $1->name, $2->name);
                                arg_counter++;
                                set_symbol_value(arg->name, arg);
                              }

arg: type ID vir              {
                                attribute arg = new_attribute();
                                arg->name = $2->name;
                                arg->type_val = $1->type_val;
                                arg->mp_offset = make_mp_offset();
                                arg->block_num = block_stack[current_block()].block_num;
                                // fprintf(filec, "%s %s, ", $1->name, $2->name);
                                arg_counter++;
                                set_symbol_value(arg->name, arg);
                              }

vlist: vlist vir ID           {
                                if(var_is_declared($3->name, block_stack[current_block()].block_num) != NULL)
                                  fprintf(stderr, "%s is already declared\n", $3->name);
                                fprintf(filec, "LOADI(0);\n");
                                $3->block_num = block_stack[current_block()].block_num;
                                $3->mp_offset = make_mp_offset();
                                set_symbol_value($3->name, $3);
                              }
| ID                          {
                                if(var_is_declared($1->name, block_stack[current_block()].block_num) != NULL)
                                  fprintf(stderr, "%s is already declared\n", $1->name);
                                fprintf(filec, "LOADI(0);\n");
                                $1->block_num = block_stack[current_block()].block_num;
                                $1->mp_offset = make_mp_offset();
                                set_symbol_value($1->name, $1);
                              }
;

vir : VIR                      {;}
;

fun_body : AO block AF        {
                                fprintf(filec, "}\n");
                                exit_block();
                              }
;

// Block
block:
decl_list inst_list            {;}
;

// I. Declarations

decl_list : decl_list decl     {;}
|                              {;}
;

decl: var_decl PV              {;}
;

var_decl : type vlist          {;}
;

type
: typename                      {
                                  $$ = new_attribute(); $$->type_val = $1->type_val; $$->name = $1->name;
                                }
;

typename
: TINT                          {
                                  $$ = new_attribute(); $$->type_val = INT; $$->name="int";
                                }
| VOID                          {
                                  $$ = new_attribute(); $$->type_val = VOID; $$->name="void";
                                }
;

// II. Intructions

inst_list: inst inst_list   {;}
| inst                      {;}
;

pv : PV                       {;}
;


inst:
exp pv                        {;}
| ao block af                 {;}
| decl pv                     {;}
| aff pv                      {;}
| ret pv                      {;}
| cond                        {;}
| loop                        {;}
| pv                          {;}
|                             {;}
;

// Accolades pour gerer l'entrée et la sortie d'un sous-bloc

ao : AO                       {
                                fprintf(filec, "ENTER_BLOCK(0);\n");
                                enter_block();
                              }
;

af : AF                       {
                                int N = block_stack[current_block()].offset;
                                exit_block();
                                fprintf(filec, "EXIT_BLOCK(%d);\n", N);
                              }
;


// II.1 Affectations

aff : ID EQ exp               {
                                if(get_nearest_symbol($1->name) == NULL) {
                                  fprintf(stderr, "%s is not declared!\n", $1->name);
                                  exit(1);
                                }
                                $1 = get_nearest_symbol($1->name);
                                $1->int_val = $3->int_val;
                                fprintf(filec, "STORE(%s);\n", get_string($1));
                              }
;


// II.2 Return
ret : RETURN exp              {
                                if(is_in_main) {
                                  fprintf(filec, "STORE(mp);\n");
                                  fprintf(filec, "EXIT_MAIN;\n");
                                }
                                else 
                                  fprintf(filec, "return;\n");
                              }
| RETURN PO PF                {
                                if(is_in_main) {
                                  fprintf(filec, "STORE(mp);\n");
                                  fprintf(filec, "EXIT_MAIN;\n");
                                }
                                else {
                                  fprintf(filec, "return;\n");
                                }
                              }
;

// II.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
if bool_cond inst_cond elsop       {;}
;

inst_cond : AO block AF {;}
| inst {;}

// la regle avec else vient avant celle avec vide pour induire une resolution
// adequate du conflit shift / reduce avec ELSE en entrée

elsop : else AO block AF      {
                                $$ = $<num>-2;
                                fprintf(filec,"End%d:\n", $$);
                                fprintf(filec, "NOP;\n");
                              }
| else inst        
                              {
                                $$ = $<num>-2;
                                fprintf(filec,"End%d:\n", $$);
                                fprintf(filec, "NOP;\n");
                              }
|                             {
                                $$ = $<num>-2;
                                fprintf(filec, "Else%d:\n", $$);
                                fprintf(filec, "NOP;\n");
                                fprintf(filec, "End%d:\n", $$);
                                fprintf(filec, "NOP;\n");
                              }
;

bool_cond : PO exp PF         {
                                $$ = $<num>0;
                                fprintf(filec, "IFN(Else%d);\n", $$);
                              }
;

if : IF                       {
                                $$ = new_label();
                              }
;

else : ELSE                   {
                                $$ = $<num>-1;
                                fprintf(filec, "GOTO(End%d);\n", $$);
                                fprintf(filec, "Else%d:\n", $$);
                              }
;

// II.4. Iterations

loop : while while_cond inst  {
                                fprintf(filec, "GOTO (Loop%d);\nEnd%d:\n", $1, $2);
                              }
;

while_cond : PO exp PF        {
                                fprintf(filec, "IFN (End%d);\n", $<num>0);  
                                $$ = $<num>0;
                              }
;
while : WHILE                 {
                                int x = new_label();
                                fprintf(filec, "Loop%d:\n", x);
                                $$ = x;
                              }
;


// II.3 Expressions
exp
// II.3.1 Exp. arithmetiques
: MOINS exp %prec UNA         { 
                                $$ = attribute_minus($2); 
                                fprintf(filec, "MINUS;\n");
                              }
         // -x + y lue comme (- x) + y  et pas - (x + y)
| exp PLUS exp                {
                                $$ = attribute_plus($1, $3); 
                                fprintf(filec, "ADDI;\n");
                              }
| exp MOINS exp               {
                                $$ = attribute_moins($1, $3); 
                                fprintf(filec, "SUBI;\n");
                              }
| exp STAR exp                {
                                $$ = attribute_star($1, $3);
                                fprintf(filec, "MULTI;\n");
                              }
| exp DIV exp                 {
                                $$ = attribute_div($1, $3);
                                fprintf(filec, "DIV;\n");
                              }
| PO exp PF                   {;}
| ID                          {
                                if(get_nearest_symbol($1->name) == NULL){
                                  fprintf(stderr, "%s is not declared!\n", $1->name);
                                  exit(1);
                                }
                                $1 = get_nearest_symbol($1->name);
                                if(is_in_main)
                                  fprintf(filec, "LOAD(%s);\n", get_string($1));
                                else 
                                  fprintf(filec, "LOAD(mp - 1 - %d);\n", $1->mp_offset+1);
                                $$ = $1;
                              }
| app                         {;}
| NUM                         {
                                $$ = $1;
                                fprintf(filec, "LOADI(%i);\n", $1->int_val);
                              }

// II.3.2. Booléens

| NOT exp %prec UNA           {fprintf(filec, "NOT;\n");}
| exp INFEQ exp                {fprintf(filec, "LEQ;\n");}
| exp SUPEQ exp                {fprintf(filec, "GEQ;\n");}
| exp INF exp                 {fprintf(filec, "LT;\n");}
| exp SUP exp                 {fprintf(filec, "GT;\n");}
| exp EQUAL exp               {fprintf(filec, "EQQ;\n");}
| exp DIFF exp                {fprintf(filec, "DIFF;\n");}
| exp AND exp                 {fprintf(filec, "AND;\n");}
| exp OR exp                  {fprintf(filec, "OR,\n");}

;

// II.4 Applications de fonctions

app : ID PO args PF           {
                                attribute id = get_symbol_value($1->name);
                                if(id == NULL)
                                  fprintf(stderr, "%s is not declared!\n", $1->name);
                                else if(id->type_val != FUNC)
                                  fprintf(stderr, "%s is not a function!\n", $1->name);
                                else if(id->arg_count > arg_counter) 
                                  fprintf(stderr, "too few arguments in %s\n", $1->name);
                                else if(id->arg_count < arg_counter)
                                  fprintf(stderr, "too many arguments in %s\n", $1->name);
                                else {
                                  fprintf(filec, "ENTER_BLOCK(%d);\n", arg_counter);
                                  fprintf(filec, "%s();\n", $1->name);
                                  fprintf(filec, "EXIT_BLOCK(%d);\n", arg_counter);
                                  arg_counter = 0;
                                }
                              }
;

args :  arglist               {
                                $<num>$=$<num>1;
                              }
|                             {;}
;

arglist : exp VIR arglist     {
                                arg_counter++;
                              }
| exp                         {
                                arg_counter++;
                                $<num>$ = arg_counter;
                              }
;




%% 
int main (int argc, char* argv[]) {

  /* Ici on peut ouvrir le fichier source, avec les messages 
     d'erreur usuel si besoin, et rediriger l'entrée standard 
     sur ce fichier pour lancer dessus la compilation.
   */
  
  filec = fopen(argv[1], "w");
  fprintf(filec, "#include \"PCode.h\"\n");

  
  yyparse ();
  

  fclose(filec);
  return 0;
} 

