%{
using namespace std;
#include<stdio.h>
#include <iostream>
#include "lex.yy.c"
#include <map>
#include <string>
#include <math.h>
void yyerror(const char *str);
void unknownVarError(string s);
void varNameAlreadyDeclaredError(string varName);
void assignmentError(int num, string varName, int capac, string move_add);
void assignmentCapacityError(string var_from, string var_to, int capac_from, int capac_to, string move_add);
int numDigits(unsigned int num);
map<string, int> vars_capac;
%}

%union{
	int int_val;
	string* str_val;
}

%token BEGINING BODY END INPUT PRINT MOVE TO ADD DELIMITER TERMINATOR
%token <int_val> CAPACITY NUM
%token <str_val> VAR_NAME STRING UNKNOWN

%type  <str_val> inner_var;

%%

language:
 BEGINING TERMINATOR declarations BODY TERMINATOR statements END TERMINATOR {printf("Valid language\n"); }
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
  CAPACITY VAR_NAME { 
	if (vars_capac.count(*$2)) {
		varNameAlreadyDeclaredError(*$2);
	} else {
		vars_capac[*$2] = $1;
	}
}		
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
  move_var
| move_num
;

add_assignment:
  add_num
| add_var
;

move_var:
  MOVE inner_var TO inner_var { 
    if (vars_capac[*$2] > vars_capac[*$4]) 
		assignmentCapacityError(*$4, *$2, vars_capac[*$4], vars_capac[*$2], "move");
  }
;

move_num:
  MOVE NUM TO inner_var {
    if (vars_capac[*$4] < numDigits($2)) assignmentError($2, *$4, vars_capac[*$4], "move");
  }
;

add_num:
  ADD NUM TO inner_var {
    if (vars_capac[*$4] < numDigits($2)) assignmentError($2, *$4, vars_capac[*$4], "add");
  }
;

add_var:
  ADD inner_var TO inner_var{ 
    if (vars_capac[*$4] < vars_capac[*$2]) 
		assignmentCapacityError(*$4, *$2, vars_capac[*$4], vars_capac[*$2], "add");
  }
;

input:
  INPUT input_ids
;

output:
  PRINT print_ids
;

input_ids:
  inner_var
| input_ids DELIMITER inner_var
;

print_ids:
  printable
| print_ids DELIMITER printable
;

printable:
  STRING
| inner_var
;

inner_var:
  VAR_NAME {if(!vars_capac.count(*$1)) unknownVarError(*$1); else $$ = $1;}
;



%%
char **fileList;
unsigned currentFile = 0;
unsigned nFiles;

void yyerror(const char *str) {
	fprintf(stderr,"Error | Line: %d\n%s\n", yylineno, str);
}

void assignmentError(int num, string varName, int capac, string move_add) {
	printf("Error | Line %d:\n Cannot %s %i to %s. %s only has capacity for %i digit number\n", 
		yylineno, move_add.c_str(), num, varName.c_str(), varName.c_str(), capac); 
	exit(0);
}

void assignmentCapacityError(string var_from, string var_to, int capac_from, int capac_to, string move_add) {
	printf("Error | Line %d:\n Cannot %s %s to %s. %s can only store values with capacity of %i or lower. %s has capacity for %i digit numbers\n", 
		yylineno, move_add.c_str(), var_from.c_str(), var_to.c_str(), var_from.c_str(), capac_from, var_to.c_str(), capac_to); 
	exit(0);
}

void varNameAlreadyDeclaredError(string varName) {
	printf("Error | Line %d:\n Variable name %s declared more than once\n", 
		yylineno, varName.c_str()); 
	exit(0);
}

void unknownVarError(string s) {
	printf("Error | Line %d:\n %s has not been declared in this scope!\n", yylineno, s.c_str()); 
	exit(0);
}

int numDigits(unsigned int num) {
	return num > 0 ? (int) log10 ((double) num) + 1 : 1;
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
