all: interpreter

interpreter: lex.yy.c parser.tab.c
	gcc -g lex.yy.c parser.tab.c -o parser

lex.yy.c: lexer.l
	flex lexer.l

parser.tab.c: parser.y
	bison -d parser.y
