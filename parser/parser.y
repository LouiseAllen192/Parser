%{
using namespace std;
#include<stdio.h>
#include <iostream>
#include "lex.yy.c"
#include <map>
#include <string>
#include <math.h>
void yyerror(char const *s);
void unknownVarError(string s);
void assignmentErrorVarToVar(string varName1, string varName2, int capac, int val);
void assignmentErrorNumToVar(int num, string varName, int capac);
void additionErrorNumToVar(int num, string varName, int varVal, int valAdded, int capac);
void additionErrorVarToVar(string varName1, string varName2, int valAdded, int capac);
void inputError(int num, string varName, int capac);
char* removeQuotes(string str);
int numDigits(unsigned int num);
map<string, int> vars;
map<string, int> vars_capac;
%}

%union{
	int int_val;
	string* str_val;
}

%token BEGINNING BODY END INPUT PRINT MOVE TO ADD DELIMITER TERMINATOR
%token <int_val> CAPACITY NUM
%token <str_val> VAR_NAME STRING UNKNOWN

%type  <str_val> inner_var;
%type  <str_val> input_var;

%%

language:
 BEGINNING TERMINATOR declarations BODY TERMINATOR statements END TERMINATOR {printf("\n\nValid language\n"); }
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
	printf("Declare %s capacity %i \n", $2->c_str(), $1);
	vars_capac[*$2] = $1; vars[*$2] = 0;
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
	printf("Move %s to %s. \n", $2->c_str(), $4->c_str());
    if (vars_capac[*$4] < numDigits(vars[*$2])) 
		assignmentErrorVarToVar(*$2, *$4, vars_capac[*$4], vars[*$2]);
	else 
		vars[*$4] = vars[*$2];
  }
;

move_num:
  MOVE NUM TO inner_var {
	printf("Move %i to %s.\n", $2, $4->c_str());
    if (vars_capac[*$4] < numDigits($2)) assignmentErrorNumToVar($2, *$4, vars_capac[*$4]);
	else vars[*$4] = $2;
  }
;

add_num:
  ADD NUM TO inner_var {
	int valAdded = $2 + vars[*$4];
	printf("Add %i to %s.  ", $2, $4->c_str());
	printf("%s = %i + %i = %i \n", $4->c_str(), vars[*$4], $2, valAdded);

    if (vars_capac[*$4] < numDigits(valAdded)) additionErrorNumToVar($2, *$4, vars[*$4], valAdded, vars_capac[*$4]);
    else vars[*$4] = $2 + vars[*$4];
  }
;

add_var:
  ADD inner_var TO inner_var {
    int valAdded = vars[*$2] + vars[*$4];
	printf("Add %s to %s.  ", $2->c_str(), $4->c_str());
	printf("%s = %i + %i = %i \n", $4->c_str(), vars[*$2], vars[*$4], valAdded);

    if (vars_capac[*$4] < numDigits(valAdded)) additionErrorVarToVar(*$2, *$4, valAdded, vars_capac[*$4]);
	else vars[*$4] = vars[*$2] + vars[*$4];
  }
;

input:
  INPUT input_ids
;

output:
  PRINT print_ids
;

input_ids:
  input_var
| input_ids DELIMITER input_var
;

input_var:
  inner_var {
  	int n;
	printf("\nInput value for %s:", $1->c_str());
	scanf("%d", &n);
	if (vars_capac[*$1] < numDigits(n)) inputError(n, *$1, vars_capac[*$1]);
	else vars[*$1] = n;
  }
;

print_ids:
  printable
| print_ids DELIMITER printable
;

printable:
  STRING {printf("%s", removeQuotes(*$1));}
| inner_var {printf("%i", vars[*$1]);}
;

inner_var:
  VAR_NAME {if(!vars.count(*$1)) unknownVarError(*$1); else $$ = $1;}
;



%%
char **fileList;
unsigned currentFile = 0;
unsigned nFiles;

void yyerror(char const *s) {
  fprintf(stderr, "error: %s\n", s);
}

void assignmentErrorVarToVar(string varName1, string varName2, int capac, int val) {
	printf("Error: Cannot move %s to %s. %s has a value of %i, %s only has capacity for %i digit number\n", 
		varName1.c_str(), varName2.c_str(), varName1.c_str(), val, varName2.c_str(), capac); exit(0);
}

void assignmentErrorNumToVar(int num, string varName, int capac) {
	printf("Error: Cannot move %i to %s. %s only has capacity for %i digit number\n", 
		num, varName.c_str(), varName.c_str(), capac); exit(0);
}

void additionErrorVarToVar(string varName1, string varName2, int valAdded, int capac) {
	printf("Error: Cannot add %s to %s. %s + %s = %i. %s only has capacity for %i digit number\n", 
		varName1.c_str(), varName2.c_str(), varName1.c_str(), varName2.c_str(), valAdded, varName2.c_str(), capac); 
    exit(0);
}

void additionErrorNumToVar(int num, string varName, int varVal, int valAdded, int capac) {
	printf("Error: Cannot add %i to %s. %s = %i. %i + %s = %i. %s only has capacity for %i digit number\n", 
		num, varName.c_str(), varName.c_str(), varVal , num, varName.c_str(), valAdded, varName.c_str(), capac); 
    exit(0);
}

void inputError(int num, string varName, int capac) {
	printf("Error: Cannot input %i to %s. %s only has capacity for %i digit number\n", 
		num, varName.c_str(), varName.c_str(), capac); exit(0);
}

void unknownVarError(string s) {
	printf("Error: %s has not been declared in this scope!\n", s.c_str()); exit(0);
}

int numDigits(unsigned int num) {
	return num > 0 ? (int) log10 ((double) num) + 1 : 1;
}

char* removeQuotes(string str) {
	char *cstr = new char[str.length() + 1];
	strcpy(cstr, str.c_str());

	char *strWithoutQuotes = (char*) malloc(strlen(cstr));
	int i, j;
	j = 0;
	for(i = 1; i < strlen(cstr); i++){
		if(cstr[i] == '"' && cstr[i-1] != '\\') {
			continue;
		}
		strWithoutQuotes[j++] = cstr[i];
	}
	delete [] cstr;
	return strWithoutQuotes;
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
