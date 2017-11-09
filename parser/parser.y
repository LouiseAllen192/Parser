%{
#include<stdio.h>
#include <iostream>
#include "lex.yy.c"
using namespace std;
void yyerror(char const *s);
%}

%union{
	int num;
	char *var;
	char *str;
	int capac;
}

%token BEGINNING BODY END
%token INPUT PRINT MOVE TO ADD
%token UNKNOWN
%token DELIMITER TERMINATOR
%token <capac> CAPACITY 
%token <num> NUM
%token <var> VAR_NAME
%token <str> STRING 

%%

language:
 BEGINNING TERMINATOR declarations BODY TERMINATOR statements END TERMINATOR {printf("Valid language\n"); }
 ;

declarations:
  declarations declaration TERMINATOR
| declaration TERMINATOR
;

statements:
  statements statement TERMINATOR
| statement TERMINATOR
;

declaration:
  CAPACITY VAR_NAME
;

statement:
  assignment 
| input
| output
;

assignment:
  move_assignment
| add_assignment
;

move_assignment:
  MOVE VAR_NAME TO VAR_NAME
| MOVE NUM TO VAR_NAME
;

add_assignment:
  ADD
;

input:
  INPUT input_ids
;

output:
  PRINT print_ids
;

input_ids:
  VAR_NAME
| input_ids DELIMITER VAR_NAME
;

print_ids:
  printable
| print_ids DELIMITER printable
;

printable:
  STRING
| VAR_NAME {$$ = $1->value;}
;



%%
char **fileList;
unsigned currentFile = 0;
unsigned nFiles;

void yyerror(char const *s) {
  fprintf(stderr, "error: %s\n", s);
}

int main(int argc, char *argv[]) {

	FILE *file;
	fileList = argv+1;
	nFiles = argc-1;
	
	if (argc < 2) {
		fprintf(stderr, "Too few arguments: %s", argv[0]);
		exit(1);
	}

	if(argc == 2) {
		currentFile = 1;
		file = fopen(argv[1], "r");
		if (!file) {
			fprintf(stderr, "I can't open file: %s", argv[1]);
			exit(1);
		}
		yyin = file;
	}

	do { yyparse();
	} while(!feof(yyin));

	return 0;
}
