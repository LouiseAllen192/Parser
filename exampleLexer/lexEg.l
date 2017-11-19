%{
#include<stdio.h>
#include<string.h>
%}
option caseless

%%
"beginning"				{printf("Found BEGINNING\n");}
"body"					{printf("Found BODY\n");}
"end"					{printf("Found END\n");}
"input"					{printf("Found INPUT\n");}
"print"					{printf("Found PRINT\n");}
"move"					{printf("Found MOVE\n");}
"to"					{printf("Found TO\n");}
"add"					{printf("Found ADD\n");}

\"([^\\\"]|\\.)*\"			{printf("Found a string %s\n", yytext);}
[Xx]+					{printf("Found int capacity %s\n", yytext);}
[A-Za-z][A-Za-z0-9-]*			{printf("Found variable name %s\n", yytext);}
[0-9]+					{printf("Found number %s\n", yytext);}
";"					{printf("Found delimiter ;\n");}
"."					{printf("Found terminator .\n");}
[\t\n]					{;}
.					{printf("Unknown found");}

%%

char **fileList;
unsigned currentFile = 0;
unsigned nFiles;

int yywrap() {
	return 0;
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

	yylex();

	return 0;
}
