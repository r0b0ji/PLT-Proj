%{
#include <stdio.h>
#include <stdlib.h>
  
#define __DEBUG__

#ifdef __DEBUG__
	#define printf(...) printf(__VA_ARGS__)
#else
	#define printf(...)
#endif

unsigned long long int SrcLineNum = 1;
%}

%%

\n			{ SrcLineNum++; fputc('\n', op); }
\*\*.*\*\*       	{ printf("\n\nComment\n"); }
[ \t]*                	{ printf("\n\nWhitespace\n"); }
"all"                   { printf("\n\nall\n"); strcpy(t, yytext); return ALL; }
"self"                  { printf("\n\nself\n"); strcpy(t, yytext); return SELF; }
"noOne"                 { printf("\n\nnoOne\n"); strcpy(t, yytext); return NOONE; }
"or"                    { printf("\n\nor\n"); strcpy(t, yytext); return OR_OP; }
"and"                   { printf("\n\nand\n"); strcpy(t, yytext); return AND_OP; }
"xor"                   { printf("\n\nxor\n"); strcpy(t, yytext); return XOR_OP; }
">="                    { printf("\n\n>=\n"); strcpy(t, yytext); return GE_OP; }
"<="                    { printf("\n\n<=\n"); strcpy(t, yytext); return LE_OP; }
"=="                    { printf("\n\n==\n"); strcpy(t, yytext); return EQ_OP; }
"!="                    { printf("\n\n!=\n"); strcpy(t, yytext); return NE_OP; }
"string"                { printf("\n\nstring\n"); strcpy(t, yytext); return STRING; }
"number"                { printf("\n\nnumber\n"); strcpy(t, yytext); return NUMBER;}
"none"                  { printf("\n\nnone\n"); strcpy(t, yytext); return NONE; }
"bool"                  { printf("\n\nbool\n"); strcpy(t, yytext); return BOOLEAN; }
"catalog"               { printf("\n\ncatalog\n"); strcpy(t, yytext); return CATALOG; }
"Game"			{ printf("\n\nGame\n"); strcpy(t, yytext); return GAME; }
"Setup"			{ printf("\n\nSetup\n"); strcpy(t, yytext); return SETUP; }
"Round"			{ printf("\n\nRound\n"); strcpy(t, yytext); return ROUND; }
"forEach"               { printf("\n\nforEach\n"); strcpy(t, yytext); return FOREACH; }
"in"                    { printf("\n\nin\n"); strcpy(t, yytext); return IN; }
"case"			{ printf("\n\ncase\n"); strcpy(t, yytext); return CASE; }
"default"		{ printf("\n\ndefault\n"); strcpy(t, yytext); return DEFAULT; }
"fallThrough"           { printf("\n\nfallThrough\n"); strcpy(t, yytext); return FALLTHROUGH; }
"switch"                { printf("\n\nswitch\n"); strcpy(t, yytext); return SWITCH; }
"loop"                  { printf("\n\nloop\n"); strcpy(t, yytext); return LOOP; }
"break"                 { printf("\n\nbreak\n"); strcpy(t, yytext); return BREAK; }
"repeat"                { printf("\n\nrepeat\n"); strcpy(t, yytext); return REPEAT; }
"until"                 { printf("\n\nuntil\n"); strcpy(t, yytext); return UNTIL; }
"loopback"              { printf("\n\nloopback\n"); strcpy(t, yytext); return LOOPBACK; }
"if"                    { printf("\n\nif\n"); strcpy(t, yytext); return IF; }
"else"                  { printf("\n\nelse\n"); strcpy(t, yytext); return ELSE; }
"return"                { printf("\n\nreturn\n"); strcpy(t, yytext); return RETURN; }
"Player"                { printf("\n\nPlayer\n"); strcpy(t, yytext); return PLAYER; }
"Pile"			{ printf("\n\nPile\n"); strcpy(t, yytext); return PILE; }
"Card"                  { printf("\n\nCard\n"); strcpy(t, yytext); return CARD; }
"Rank"                  { printf("\n\nrank\n"); strcpy(t, yytext); return RANK; }
"record"                { printf("\n\nrecord\n"); strcpy(t, yytext); return RECORD; }
"attribute"             { printf("\n\nattribute\n"); strcpy(t, yytext); return ATTRIBUTE; }
"null"                  { printf("\n\nnull\n"); strcpy(t, yytext); return NULL_CONSTANT; }
"~"                     { printf("\n\n~\n"); strcpy(t, yytext); return UMINUS; }
"true"|"false"          { printf("\n\n%s\n", yytext); strcpy(t, yytext); return BOOLEAN_CONSTANT; }
"global"                  { printf("\n\nglobal\n"); strcpy(t, yytext); return GLOBAL; }
[+-]?[0-9]+(\.[0-9]+)?  { printf("\n\nNUMBER_CONSTANT: %s\n", yytext); strcpy(t, yytext);
                          return NUMBER_CONSTANT; }
[_a-zA-Z]+[_a-zA-Z0-9]* { printf("\n\nID: %s\n", yytext); strcpy(t, yytext); return ID; }
\".*\"                  { printf("\n\nSTRING_LITERAL: %s\n", yytext); strcpy(t, yytext);
                          return STRING_LITERAL; }
.                       { printf("\n\nUnknown or newline: \"%s\"\n", yytext); strcpy(t, yytext);
			  fflush(NULL);
                          return yytext[0];}

%%

char *t = (char *)&yylval;
FILE *op = NULL;
FILE *intrmd = NULL;

int main(void)
{
	op = fopen("./cgdl.out", "w");
	if ( !op )
	{
		fprintf(stderr, "Error: Failed to create the target C++ code\n");
		exit(-1);
	}

	fprintf(op, "\n\n enum CgdlConstants { all = 1, self, noOne, null }; \n\n");

	intrmd = fopen("./intermediate", "w");
	if ( !intrmd )
	{
		fprintf(stderr, "Error: Failed to create intermediate representation\n");
		exit(-1);
	}

	(void)yyunput;
	(void)input;
	yyparse();
	fclose(op);
	fclose(intrmd);
	return 0;
}
                          
