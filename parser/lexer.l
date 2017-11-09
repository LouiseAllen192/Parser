%{
#include "parser.tab.h"
#include<stdio.h>
#include<string.h>
%}
option caseless

%%

"beginning"				{printf("Found BEGINNING\n"); return BEGINNING;}
"body"					{printf("Found BODY\n"); return BODY;}
"end"					{printf("Found END\n"); return END;}
"input"					{printf("Found INPUT\n"); return INPUT;}
"print"					{printf("Found PRINT\n"); return PRINT;}
"move"					{printf("Found MOVE\n"); return MOVE;}
"to"					{printf("Found TO\n"); return TO;}
"add"					{printf("Found ADD\n"); return ADD;}
";"						{printf("Found delimiter ;\n"); return DELIMITER;}
"."						{return TERMINATOR;}

\"([^\\\"]|\\.)*\"		{printf("Found a string %s\n", yytext);
						yylval.str = strdup(yytext); 
						return STRING;}

[Xx]+					{printf("Found int capacity %s\n", yytext);
						yylval.capac = yyleng;
						return CAPACITY;}

[A-Za-z][A-Za-z0-9-]*	{printf("Found variable name %s\n", yytext); 
						yylval.var = yytext;
						return VAR_NAME;}

[0-9]+					{printf("Found number %s\n", yytext);
						yylval.num = atoi(yytext); 
						return NUM;}


[\t\n]					{;}

%%




