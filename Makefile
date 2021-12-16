SRC_DIR=src
TST_DIR=tst

all : 	lang

syntax : lexic	$(SRC_DIR)/lang.y
	bison -v -y  -d  $(SRC_DIR)/lang.y
lexic : $(SRC_DIR)/lang.l
	flex $(SRC_DIR)/lang.l

PCode/PCode.o : PCode/PCode.c PCode/PCode.h
	cd $(SRC_DIR)/PCode; make pcode

lang		:	syntax $(SRC_DIR)/Attribute.c $(SRC_DIR)/Table_des_symboles.c $(SRC_DIR)/Table_des_chaines.c $(SRC_DIR)/PCode/PCode.o
	gcc -I$(SRC_DIR) -o lang lex.yy.c y.tab.c $(SRC_DIR)/PCode/PCode.o $(SRC_DIR)/Attribute.c $(SRC_DIR)/Table_des_symboles.c $(SRC_DIR)/Table_des_chaines.c

test : lang
	./lang $(SRC_DIR)/PCode/pcode-ex1.c < $(TST_DIR)/ex1.c
	./lang $(SRC_DIR)/PCode/pcode-ex2.c < $(TST_DIR)/ex2.c
	./lang $(SRC_DIR)/PCode/pcode-ex3.c < $(TST_DIR)/ex3.c
	./lang $(SRC_DIR)/PCode/pcode-ex4.c < $(TST_DIR)/ex4.c
	./lang $(SRC_DIR)/PCode/pcode-ex5.c < $(TST_DIR)/ex5.c
	./lang $(SRC_DIR)/PCode/pcode-ex6.c < $(TST_DIR)/ex6.c
	./lang $(SRC_DIR)/PCode/pcode-ex7.c < $(TST_DIR)/ex7.c
clean		:	
	rm -f lex.yy.c *.o y.tab.h y.tab.c lang *~ y.output; rm -f $(SRC_DIR)/PCode/pcode*.c; cd $(SRC_DIR)/PCode; make clean

