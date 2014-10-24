%{
#include "stdlib.h"
#include "stdio.h"
#include "parser.tab.h"
%}

digit [0-9]
letter [a-zA-Z]

%{
#define PLUS 102;
#define MINUS 103;
#define SLASH 104;
#define TIMES 105;
#define LSS 106;
#define GTR 107;
#define LEQ 108;
#define GEQ 109;
#define EQLEQL 110;
#define NEQ 111;
#define AND 112;
#define OR 113;
#define EXL 114;
#define SEMICOLON 115;
#define BECOMES 118;
#define LPAREN 116;
#define RPAREN 117;
#define BEGINSYM 119;
#define ENDSYM 120;
#define IFSYM 121;
#define THENSYM 122;
#define ELSESYM 123;
#define WHILESYM 124;
#define DOSYM 125;
#define PRINTSYM 126;
#define INPUTSYM 127;
#define IDENT 100;
#define VALUE 101;
#define UNKNOWN 128;
%}

%option noyywrap


%%
"+" {return PLUS;}
"-" {return MINUS;}
"/" {return SLASH;}
"*" {return TIMES;}
"<" {return LSS;}
">" {return GTR;}
"<=" {return LEQ;}
">=" {return GEQ;}
"==" {return EQLEQL;}
"!=" {return NEQ;}
"&&" {return AND;}
"||" {return OR;}
"!" {return EXL;}
";" {return SEMICOLON;}
":=" {return BECOMES;}
"(" {return LPAREN;}
")" {return RPAREN;}
"begin" {return BEGINSYM;}
"end" {return ENDSYM;}
"if" {return IFSYM;}
"then" {return THENSYM;}
"else" {return ELSESYM;}
"while" {return WHILESYM;}
"do" {return DOSYM;}
"print" {return PRINTSYM;}
"input" {return INPUTSYM;}
[0-9]*\.?[0-9]+ { yylval.value = atof(yytext); return VALUE;}
%.*$ {}
[_a-zA-Z][_a-zA-Z0-9]* { strcpy (yylval.name,yytext); return IDENT;}
[ \t\n\r\f] {}
. { printf("Unknown character [%c]\n");
	return UNKNOWN; }


%%
/*int main(int argc, char *argv[]) {
stdin = fopen(argv[1], "r");
int num;
	do{
	num = yylex();
	printf("%d\n", num);
	}while(num != 0 && num!= 128);
	return 0;
}*/
