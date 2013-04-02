%{
#include <stdio.h>
  
#define __DEBUG__

#ifdef __DEBUG__
	#define printf(...) printf(__VA_ARGS__)
#else
	#define printf(...)
#endif

%}


%%


\*\*.*\*\*       	{ printf("\n\nComment\n"); }
[ \t\n]*                { printf("\n\nWhitespace\n"); }
"all"                   { printf("\n\nall\n"); return ALL; }
"self"                  { printf("\n\nself\n"); return SELF; }
"noOne"                 { printf("\n\nnoOne\n"); return NOONE; }
"or"                    { printf("\n\nor\n"); return OR_OP; }
"and"                   { printf("\n\nand\n"); return AND_OP; }
"xor"                   { printf("\n\nxor\n"); return XOR_OP; }
">="                    { printf("\n\n>=\n"); return GE_OP; }
"<="                    { printf("\n\n<=\n"); return LE_OP; }
"=="                    { printf("\n\n==\n"); return EQ_OP; }
"!="                    { printf("\n\n!=\n"); return NE_OP; }
"string"                { printf("\n\nstring\n"); return STRING; }
"number"                { printf("\n\nnumber\n"); return NUMBER;}
"none"                  { printf("\n\nnone\n"); return NONE; }
"bool"                  { printf("\n\nbool\n"); return BOOLEAN; }
"catalog"               { printf("\n\ncatalog\n"); return CATALOG; }
"forEach"               { printf("\n\nforEach\n"); return FOREACH; }
"in"                    { printf("\n\nin\n"); return IN; }
"fallThrough"           { printf("\n\nfallThrough\n"); return FALLTHROUGH; }
"endLookup"             { printf("\n\nendLookup\n"); return ENDLOOKUP; }
"lookup"                { printf("\n\nlookup\n"); return LOOKUP; }
"loop"                  { printf("\n\nloop\n"); return LOOP; }
"endLoop"               { printf("\n\nendLoop\n"); return ENDLOOP; }
"repeat"                { printf("\n\nrepeat\n"); return REPEAT; }
"until"                 { printf("\n\nuntil\n"); return UNTIL; }
"loopback"              { printf("\n\nloopback\n"); return LOOPBACK; }
"if"                    { printf("\n\nif\n"); return IF; }
"then"                  { printf("\n\nthen\n"); return THEN; }
"else"                  { printf("\n\nelse\n"); return ELSE; }
"return"                { printf("\n\nreturn\n"); return RETURN; }
"Player"                { printf("\n\nPlayer\n"); return PLAYER; }
"Card"                  { printf("\n\nCard\n"); return CARD; }
"Deck"                  { printf("\n\nDeck\n"); return DECK; }
"Pile"                  { printf("\n\nPile\n"); return PILE; }
"Rank"                  { printf("\n\nrank\n"); return RANK; }
"record"                { printf("\n\nrecord\n"); return RECORD; }
"attribute"             { printf("\n\nattribute\n"); return ATTRIBUTE; }
"null"                  { printf("\n\nnull\n"); return NULL_CONSTANT; }
"~"                     { printf("\n\n~\n"); return UMINUS; }
"true"|"false"          { printf("\n\n%s\n", yytext); return BOOLEAN_CONSTANT; }
"global"                  { printf("\n\nglobal\n"); return GLOBAL; }
[+-]?[0-9]+(\.[0-9]+)?  { printf("\n\nNUMBER_CONSTANT: %s\n", yytext);
                          return NUMBER_CONSTANT; }
[_a-zA-Z]+[_a-zA-Z0-9]* { printf("\n\nID: %s\n", yytext); return ID; }
\".*\"                  { printf("\n\nSTRING_LITERAL: %s\n", yytext);
                          return STRING_LITERAL; }
.                       { printf("\n\nUnknown or newline: \"%s\"\n", yytext);
			              fflush(NULL);
                          return yytext[0];}

%%

