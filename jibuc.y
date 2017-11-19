%{
#include<stdio.h>
#include<iostream>
using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);
%}

%union {
	int ival;
}

%token BEGINNING END BODY
%%
jibuc: BEGINNING BODY END
	{printf("Is a valid language instance\n");}

%%

int main() {
	do { yyparse();
	} while(!feof(yyin));
}

int yyerror(char *s) {
	fprintf(stderr, "Error: %s\n", s);
	exit(-1);
}

