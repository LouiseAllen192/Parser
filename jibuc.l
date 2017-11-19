%{
using namespace std;
#include "jibuc.tab.h"
#include <iostream>
#include <cstdio>
#define YY_DECL extern "C" int yylex()
#undef yywrap
%}

%%

\n 				;
[\t]				;
"BEGINNING | beginning"		{return BEGINNING;}
"BODY | body"			{return BODY;}
"END | end"			{return END;}

%%
char **fileList;
unsigned currentFile = 0;
unsigned nFiles;

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
	if(argc > 2) {
		yywrap();
	} 
	
	yylex();

	return 0;
}

int yywrap(){
	FILE *file = NULL;

	if ((currentFile != 0) && (nFiles > 1) && (currentFile < nFiles)) {
		fclose(yyin);
	}

	while(fileList[currentFile] != (char *)0) {
		file = fopen(fileList[currentFile++], "r");
		if (file != NULL) {
			yyin = file;
			break;
		}
	}
	return (file ? 0 : 1);
}
