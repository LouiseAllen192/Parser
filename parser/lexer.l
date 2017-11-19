%{
using namespace std;
#include "parser.tab.h"
#include<stdio.h>
#include<string>
%}
%option yylineno
%%

(?i:begining)				{return BEGINING;}
(?i:body)					{return BODY;}
(?i:end)					{return END;}
(?i:input)					{return INPUT;}
(?i:print)					{return PRINT;}
(?i:move)					{return MOVE;}
(?i:to)						{return TO;}
(?i:add)					{return ADD;}
";"							{return DELIMITER;}
"."							{return TERMINATOR;}

\"([^\\\"]|\\.)*\"		{yylval.str_val = new string(yytext); return STRING;}

[Xx]+					{yylval.int_val = yyleng; return CAPACITY;}

[A-Za-z][A-Za-z0-9-]*	{yylval.str_val = new string(yytext); return VAR_NAME;}

[0-9]+					{yylval.int_val = atoi(yytext); return NUM;}

[\t\n]					{;}
" "						{;}
.						{printf("Unknown found: %s\n", yytext);
						yylval.str_val = new string(yytext);
						return UNKNOWN;}

%%


