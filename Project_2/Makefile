LEX = lex
YACC = yacc -d

CC = gcc


all: parser clean

parser: y.tab.o lex.yy.o
	$(CC) -o parser y.tab.o lex.yy.o 
	./parser < cs315f17_group19.test.txt


lex.yy.o: lex.yy.c y.tab.h
lex.yy.o y.tab.o: y.tab.c


y.tab.c y.tab.h: cs315f17_group19.yacc.y
	$(YACC) -v cs315f17_group19.yacc.y


lex.yy.c: cs315f17_group19.lex.l
	$(LEX) cs315f17_group19.lex.l

clean:
	-rm -f *.o lex.yy.c *.tab.* parser *.output
