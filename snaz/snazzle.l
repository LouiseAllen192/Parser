%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()
unsigned long charCount = 0, wordCount = 0, lineCount = 0;
#undef yywrap
%}
word [^ \t\n]+
eol \n
%%
{word} {wordCount++; charCount += yyleng;}
{eol} {charCount++; lineCount++;}
. {charCount++;}
%%
char **fileList;
unsigned currentFile = 0;
unsigned nFiles;
unsigned long totalCC = 0;
unsigned long totalWC = 0;
unsigned long totalLC = 0;


int main(int argc, char *argv[]) {
	FILE *file;
	fileList = argv+1;
	nFiles = argc-1;
	
	if (argc < 2) {
		fprintf(stderr, "Too few arguments", argv[0]);
		exit(1);
	}

	if(argc == 2) {
		currentFile = 1;
		file = fopen(argv[1], "r");
		if (!file) {
			fprintf(stderr, "I can't open file!", argv[1]);
			exit(1);
		}
		yyin = file;
	}
	if(argc > 2) {
		yywrap();
	} 
	
	yylex();

	if (argc > 2) {
		printf("%8lu %8lu %8lu %s\n", lineCount, wordCount, 
		charCount, fileList[currentFile - 1]);
		totalCC += charCount;
		totalWC += wordCount;
		totalLC += lineCount;
		printf("%8lu %8lu %8lu total\n", totalLC, totalWC, totalCC);
	} else {
		printf("%8lu %8lu %8lu\n", lineCount, wordCount, charCount);
	}

	return 0;
}

int yywrap(){
	FILE *file = NULL;

	if ((currentFile != 0) && (nFiles > 1) && (currentFile < nFiles)) {
		printf("%8lu %8lu %8lu %s\n", lineCount, wordCount, 
		charCount, fileList[currentFile - 1]);
		totalCC += charCount;
		totalWC += wordCount;
		totalLC += lineCount;
		charCount = lineCount = wordCount = 0;
		fclose(yyin);
	}

	while(fileList[currentFile] != (char *)0) {
		file = fopen(fileList[currentFile++], "r");
		if (file != NULL) {
			yyin = file;
			break;
		}
		fprintf(stderr, "I can't open file!", fileList[currentFile-1]);
	}
	return (file ? 0 : 1);
}
