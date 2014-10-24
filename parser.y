%{

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#define ID_SIZE 100
#define MAX_CHILDREN 3
#define STATEMENT 42

struct Node* make_node(int, double, char*);
void attach_node(struct Node*, struct Node*);
void print_tree(struct Node*, int);
int yywrap();
void yyerror(const char* str);
double eval_expression(struct Node*);
void eval_statement(struct Node*);
struct Node* root;
char* variableNames[1000];
double variableValues[1000];
int nextVariable = 0;

%}

%union {

	char name[100];
	double value;
	struct Node *node;
}

%token <name> IDENT 100
%token <value> VALUE 101
%token PLUS 102
%token MINUS 103
%token SLASH 104
%token TIMES 105
%token LSS 106
%token GTR 107
%token LEQ 108
%token GEQ 109
%token EQLEQL 110
%token NEQ 111
%token AND 112
%token OR 113
%token EXL 114
%token SEMICOLON 115
%token LPAREN 116
%token RPAREN 117
%token BECOMES 118
%token BEGINSYM 119
%token ENDSYM 120
%token IFSYM 121
%token THENSYM 122
%token ELSESYM 123
%token WHILESYM 124
%token DOSYM 125
%token PRINTSYM 126
%token INPUTSYM 127

%error-verbose
%type <node> statement stmt printstmt whilestmt ifstmt ifelsestmt stmtsequence assign exp andterm compareterm plusminusterm term nodeterm factor 
%%

root: statement	{
    root = $1;
}

statement: stmt statement {
	$$ = make_node(STATEMENT, 0, "");
	attach_node($$, $1);
	attach_node($$, $2);
}
	  | {
	$$ = NULL;
}

stmt: assign {
	$$ = $1;
}
    | ifstmt {
	$$ = $1;
}
    | ifelsestmt {
	$$ = $1;
}
    | whilestmt {
	$$ = $1;
}
    | printstmt {
	$$ = $1;
}
    | stmtsequence {
	$$ = $1;
}

printstmt: PRINTSYM exp SEMICOLON {
	 $$ = make_node(PRINTSYM, 0, "");
	 attach_node($$, $2);
}

whilestmt: WHILESYM exp DOSYM stmt {
	$$ = make_node(WHILESYM, 0, "");
	attach_node($$, $2);
	attach_node($$, $4); 
}

ifstmt: IFSYM exp THENSYM stmt {
      $$ = make_node(IFSYM, 0, "");
      attach_node($$, $2);
      attach_node($$, $4);
}

ifelsestmt: IFSYM exp THENSYM stmt ELSESYM stmt {
	$$ = make_node(IFSYM, 0, "");
	attach_node($$, $2);
	attach_node($$, $4);
	attach_node($$, $6);  
}

stmtsequence: BEGINSYM statement ENDSYM {
       $$ = $2;
}

assign: IDENT BECOMES exp SEMICOLON {
	$$ = make_node(BECOMES, 0, "");
	attach_node($$, make_node(IDENT, 0, $1));
	attach_node($$, $3);      
}

exp: exp OR andterm {
	$$ = make_node(OR, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);    
}
    | andterm {
	$$ = $1;
}

andterm: andterm AND compareterm {
	$$ = make_node(AND, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);       
}
       | compareterm {
	$$ = $1;
}

compareterm: compareterm LSS plusminusterm {
	$$ = make_node(LSS, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);	
}
	| compareterm GTR plusminusterm {
	$$ = make_node(GTR, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);
}
	| compareterm LEQ plusminusterm	{
	$$ = make_node(LEQ, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);
}
	| compareterm GEQ plusminusterm	{
	$$ = make_node(GEQ, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);
}
	| compareterm EQLEQL plusminusterm {
	$$ = make_node(EQLEQL, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);
}
	| compareterm NEQ plusminusterm {
	$$ = make_node(NEQ, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);
}
	| plusminusterm	{
	$$ = $1;
}

plusminusterm: plusminusterm PLUS term {
	$$ = make_node(PLUS, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);      
}
      | plusminusterm MINUS term {
	$$ = make_node(MINUS, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);
}
      | term {
	$$ = $1;
}

term: term TIMES nodeterm {
	$$ = make_node(TIMES, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);
}
    | term SLASH nodeterm {
	$$ = make_node(SLASH, 0, "");
	attach_node($$, $1);
	attach_node($$, $3);
}
    | nodeterm {
	$$ = $1;
}

nodeterm: EXL nodeterm {
	$$ = make_node(EXL, 0, "");
	attach_node($$, $2);     
}
     | factor {
	$$ = $1;
}

factor: VALUE {
	$$ = make_node(VALUE, $1, "");  
}
      | INPUTSYM {
	$$ = make_node(INPUTSYM, 0, "");
}
      | IDENT {
	$$ = make_node(IDENT, 0, $1);
}
      | LPAREN exp RPAREN {
	$$ = $2;
}
%%

int yywrap() {
	return 1;
}

void yyerror(const char* str) {
	fprintf(stderr, "Didn't compile properly '%s'.\n", str);
}

struct Node {
	int type;
 	double value;
 	char id[ID_SIZE];
 	int num_children;
 	struct Node* children[MAX_CHILDREN];
};

struct Node* make_node(int type, double value, char* id) {
 	int i;
 	struct Node* node = malloc(sizeof(struct Node));

 	node->type = type;
 	node->value = value;
 	strcpy(node->id, id);
 	node->num_children = 0;
  
	for(i = 0; i < MAX_CHILDREN; i++) {
		node->children[i] = NULL;
  	}
	return node;
}

void attach_node(struct Node* parent, struct Node* child) {
 	parent->children[parent->num_children] = child;
 	parent->num_children++;
 	assert(parent->num_children <= MAX_CHILDREN);
}

void print_tree(struct Node* node, int tabs) {
 	int i;

 	if(!node) return;
 	for(i = 0; i < tabs; i++) {
    		printf("    ");
 	}	

 	switch(node->type) {
  	case IDENT: printf("IDENTIFIER: %s\n", node->id); 
	break;
   	case VALUE: printf("VALUE: %lf\n", node->value); 
	break;
   	case PLUS: printf("PLUS:\n"); 
	break;
   	case MINUS: printf("MINUS:\n"); 
	break;
   	case SLASH: printf("SLASH:\n"); 
	break;
   	case TIMES: printf("TIMES:\n"); 
	break;
   	case LSS: printf("LESS THAN:\n"); 
	break;
   	case GTR: printf("GREATER:\n"); 
	break;
   	case LEQ: printf("LESS THAN OR EQUAL:\n"); 
	break;
   	case GEQ: printf("GREATER THAN OR EQUALL:\n"); 
	break;
   	case EQLEQL: printf("EQUALS:\n"); 
	break;
   	case NEQ: printf("NOT EQUALS:\n"); 
	break;
   	case AND: printf("AND:\n"); 
	break;
   	case OR: printf("OR:\n"); 
	break;
   	case EXL: printf("NOT:\n"); 
	break;
   	case BECOMES: printf("BECOMES:\n"); 
	break;
   	case IFSYM: printf("IF:\n"); 
	break;
   	case WHILESYM: printf("WHILE:\n"); 
	break;
   	case PRINTSYM: printf("PRINT:\n"); 
	break;
   	case INPUTSYM: printf("INPUT:\n"); 
	break;
   	case STATEMENT: printf("STATEMENT:\n"); 
	break;
   	default:
		printf("%d is not a valid node type.\n", node->type);
     		exit(1);
  	}
  	
	for(i = 0; i < node->num_children; i++) {
    		print_tree(node->children[i], tabs + 1);
  	}
}

int searchTable(char* name) {
	int i;
  	for(i = 0; i < nextVariable; i++) {
    		if(strcmp(variableNames[i], name) == 0)
      			return i;
  	}
  	return -1;
}

double eval_expression(struct Node* node) {
	double returnValue = 0;
	switch(node->type) {
    		case IDENT: if(searchTable(node->id) != -1) { 
			returnValue = variableValues[searchTable(node->id)];
 			} 
			else { 
				printf("Identifier is undeclared %s.", node->id); 
				exit(1); 
			} 
		break;
   		case VALUE: returnValue = node->value; 
		break;
    		case INPUTSYM: printf("Input: "); 
		scanf("%lf", &returnValue); 
		break;
    		case PLUS: returnValue = eval_expression(node->children[0]) + eval_expression(node->children[1]); 
		break;
    		case MINUS: returnValue = eval_expression(node->children[0]) - eval_expression(node->children[1]); 
		break;
    		case SLASH: returnValue = eval_expression(node->children[0]) / eval_expression(node->children[1]); 
		break;
    		case TIMES: returnValue = eval_expression(node->children[0]) * eval_expression(node->children[1]); 
		break;
    		case LSS: returnValue = (eval_expression(node->children[0]) < eval_expression(node->children[1])) ? 1 : 0; 
		break;
    		case GTR: returnValue = (eval_expression(node->children[0]) > eval_expression(node->children[1])) ? 1: 0; 
		break;
    		case LEQ: returnValue = (eval_expression(node->children[0]) <= eval_expression(node->children[1])) ? 1 : 0; 
		break;
    		case GEQ: returnValue = (eval_expression(node->children[0]) >= eval_expression(node->children[1])) ? 1: 0; 
		break;
    		case EQLEQL: returnValue = (eval_expression(node->children[0]) == eval_expression(node->children[1])) ? 1 : 0; 
		break;
    		case NEQ: returnValue = (eval_expression(node->children[0]) != eval_expression(node->children[1])) ? 1: 0; 
		break;
    		case AND: returnValue = (((eval_expression(node->children[0]) != 0) ? 1 : 0) && (eval_expression(node->children[1]) != 0) ? 1 : 0); 
		break;
    		case OR: returnValue = (((eval_expression(node->children[0]) != 0) ? 1 : 0) || (eval_expression(node->children[1]) != 0) ? 1 : 0); 
		break;
    		case EXL: returnValue = !((eval_expression(node->children[0]) != 0) ? 1 : 0); 	
		break;
    		default: printf("%d is not a valid expression node type.\n", node->type); exit(1);
  		}
	return returnValue;
}

void eval_statement(struct Node* node) {
	switch(node->type) {
    	case STATEMENT: eval_statement(node->children[0]); 
		if(node->children[1] != NULL) eval_statement(node->children[1]); 
	break;
    	case PRINTSYM: printf("%lf\n", eval_expression(node->children[0])); 
	break;
    	case WHILESYM: while(eval_expression(node->children[0]) != 0) { 
			eval_statement(node->children[1]); 
			}	 
	break;
    	case IFSYM: if(eval_expression(node->children[0]) != 0) { 
			eval_statement(node->children[1]); 
			} 
			else if(node->children[2] != NULL) { 
				eval_statement(node->children[2]); 
			}	 
	break;
    	case BECOMES: if(searchTable((node->children[0])->id) == -1) { 
			variableNames[nextVariable] = (char*) malloc(ID_SIZE);
			strcpy(variableNames[nextVariable], (node->children[0])->id); 
			variableValues[nextVariable] = eval_expression(node->children[1]); 
			nextVariable++; 
			} 
		     	else { 
				variableValues[searchTable((node->children[0])->id)] = eval_expression(node->children[1]);
	             	}	 
			break;
    	default: eval_expression(node);
  	}
}

int main(int argc, char* argv[]) {
	if(argc != 2) {
		printf("Argv[1] only. \n");
		return 1;
	}
	FILE* orig_stdin = stdin;
	stdin = fopen(argv[1], "r");
	if(stdin == NULL) {
		printf("Error opening the file. \n");
		return 2;
	}
	yyparse();
        print_tree(root, 0);
	fclose(stdin);
	stdin = orig_stdin;
	eval_statement(root);
	return 0;
}
