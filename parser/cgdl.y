%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyerror(char *s);
void display(char *s, int line);

#define __DEBUG__

#ifdef __DEBUG__
	#define print(nt) display(#nt, __LINE__)
	#define fprintf(...) printf("%d: \n", __LINE__); /* fprintf(op, "%d: ", __LINE__); */ fprintf(__VA_ARGS__)
	// #define fprintf(...) fprintf(op, "%d: ", __LINE__)
#else
	#define print(nt)
	#define fprintf(...)
#endif

extern unsigned long long int SrcLineNum;

extern char *t;
extern char type[];
extern char *yytext;

int yylex(void);

#define YYSTYPE char*

extern FILE *op;

extern FILE *intrmd;

%}

%token ID STRING_LITERAL
%token LE_OP GE_OP EQ_OP NE_OP 
%token AND_OP OR_OP XOR_OP
%token GLOBAL
%token BOOLEAN NONE NUMBER STRING RANK CARD PLAYER PILE CONST
%token GAME SETUP ROUND
%token CATALOG RECORD ATTRIBUTE
%token NUMBER_CONSTANT BOOLEAN_CONSTANT NULL_CONSTANT
%token FOREACH IN REPEAT UNTIL LOOP LOOPBACK BREAK SWITCH CASE DEFAULT
       FALLTHROUGH IF ELSE RETURN
%token UMINUS ALL NOONE SELF

%start lines


%%

lines
        : lines translation_unit '\n' { print(lines); }
        | lines '\n' { print(lines); }
        | /*empty*/ { print(lines); }
	;

identifier
	: ID { $$ = strdup(yytext); } 
       
constant
        : NUMBER_CONSTANT { print(constant); $$ = strdup(yytext); }
        | BOOLEAN_CONSTANT { print(constant); $$ = strdup(yytext); }
        | NULL_CONSTANT { print(constant); $$ = strdup(yytext); }
        | STRING_LITERAL { print(constant); $$ = strdup(yytext); }
        | visibility_constant { print(constant); $$ = strdup(yytext); }
	;

visibility_constant
        : ALL { print(visibility_constant); $$ = strdup(yytext); }
        | NOONE { print(visibility_constant); $$ = strdup(yytext); }
        | SELF { print(visibility_constant); $$ = strdup(yytext); }
        ;

primary_expression
	: identifier { print(primary_expression); }
	| constant { print(primary_expression); }
        | '|' expression '|' { print(primary_expression); $$ = strdup(yytext); sprintf($$, "( %s )", $2); }
        ;

postfix_expression
        : primary_expression { print(postfix_expression); }
        | postfix_expression '[' expression ']' { print(postfix_expression); sprintf($$, "%s[ %s ]", $1, $3); }
        | postfix_expression '[' expression ':' expression ']' 
                                                { print(postfix_expression); sprintf($$, "%s[ %s: %s ]", $1, $3, $5); }
	| postfix_expression '(' ')' { print(postfix_expression); sprintf($$, "%s()", $1); }
        | postfix_expression '(' argument_expression_list ')'
                                     { print(postfix_expression); sprintf($$, "%s(%s)", $1, $3); }
        | postfix_expression '.' identifier { print(postfix_expression); sprintf($$, "%s.%s", $1, $3); }
	| postfix_expression '(' type_specifier ':' identifier ')' { print(postfix_expression); print(attribute_addition);
								sprintf($$, "%s(%s:%s)", $1, $3, $5); }
        ;

argument_expression_list
        : assignment_expression { print(argument_expression_list); }
        | argument_expression_list ',' assignment_expression
                                { print(argument_expression_list); sprintf($$, "%s, %s", $1, $3); }
        ;

unary_expression
	: postfix_expression { print(unary_expression); }
        | unary_operator unary_expression { print(unary_expression); sprintf($$, "%s%s", $1, $2); }
        ;

unary_operator
        : '@' { print(unary_expression); $$ = strdup("&"); }
        | UMINUS { print(unary_expression); $$ = strdup(yytext); $$ = strdup("-"); }
        | '!' { print(unary_expression); $$ = strdup(yytext); }
        ;

multiplicative_expression
        : unary_expression { print(multiplicative_expression); }
        | multiplicative_expression '*' unary_expression
        { print(multiplicative_expression); fprintf(op, "%s * %s", $1, $3); }
        | multiplicative_expression '/' unary_expression
        { print(multiplicative_expression); fprintf(op, "%s / %s", $1, $3); }
        | multiplicative_expression '%' unary_expression
        { print(multiplicative_expression); fprintf(op, "%s %% %s", $1, $3); }
        ;

additive_expression
        : multiplicative_expression { print(additive_expression); }
        | additive_expression '+' multiplicative_expression
          { print(additive_expression);
		printf("$1 : %s\n", $1);
		printf("$3 : %s\n", $3);
		sprintf($$, "%s + %s", $1, $3);
	  }
        | additive_expression '-' multiplicative_expression
          { print(additive_expression);
		sprintf($$, "%s - %s", $1, $3); }
        ;


relational_expression
        : additive_expression { print(relational_expression); }
        | relational_expression '<' additive_expression
                { print(relational_expression);
			sprintf($$, "%s < %s", $1, $3); }
        | relational_expression '>' additive_expression
                { print(relational_expression);
			sprintf($$, "%s > %s", $1, $3); }
        | relational_expression LE_OP additive_expression
                { print(relational_expression);
			sprintf($$, "%s <= %s", $1, $3); }
        | relational_expression GE_OP additive_expression
                { print(relational_expression);
			sprintf($$, "%s >= %s", $1, $3); }
        ;

equality_expression
        : relational_expression
                { print(equality_expression); }
        | equality_expression EQ_OP relational_expression
                { print(equality_expression);
			sprintf($$, "%s == %s", $1, $3); }        
        | equality_expression NE_OP relational_expression
                { print(equality_expression);
			fprintf(op, "%s != %s", $1, $3); }
        ;

logical_and_expression
        : equality_expression
                { print(logical_and_expression); }
        | logical_and_expression AND_OP equality_expression
                { print(logical_and_expression);
			sprintf($$, "%s && %s", $1, $3); }                
        ;

logical_or_expression
        : logical_and_expression
                        { print(logical_or_expression); }
        | logical_or_expression OR_OP logical_and_expression
                        { print(logical_or_expression);
				fprintf(op, "%s || %s", $1, $3); }      
        ;

logical_xor_expression
	    : logical_or_expression
                        { print(logical_xor_expression); }
        | logical_xor_expression XOR_OP logical_or_expression
                        { print(logical_xor_expression);
				fprintf(op, "%s xor %s", $1, $3); }                
        ;

assignment_expression
        : logical_xor_expression
                        { print(assignment_expression); }
        | unary_expression '=' assignment_expression
                        { print(assignment_expression);
				sprintf($$, "%s = %s", $1, $3); }               
        ;

expression
        : assignment_expression
                        { print(expression); $$ = strdup($1); }
        | expression ',' assignment_expression
                        { print(expression);
				fprintf(op, "%s, %s", $1, $3); }             
        ;

constant_expression
        : logical_xor_expression { print(constant_expression); }

declaration
        : declaration_specifiers ';' { print(declaration);
					fprintf(op, "%s;", $1);  }
        | declaration_specifiers init_declarator_list ';'
                { print(declaration);
			fprintf(op, "%s %s;", $1, $2); }      
        ;

declaration_specifiers
        : storage_class_specifier
                { print(declaration_specifiers); fprintf(op, "%s", $1); }                                        
        | storage_class_specifier declaration_specifiers
                { print(declaration_specifiers);
			fprintf(op, "%s %s", $1, $2); }                    
        | type_specifier
                { print(declaration_specifiers); /* fprintf(op, "%s", $1); */ }                                   
        | type_specifier '[' ']'
		{ print(declaration_specifiers); fprintf(op, "%s[]", $1); }
	| type_specifier '[' expression ']'
		{ print(declaration_specifiers); fprintf(op, "%s[%s]", $1, $2); }
        | type_specifier declaration_specifiers
                { print(declaration_specifiers); fprintf(op, "%s %s", $1, $2); }         
        | type_qualifier
                { print(declaration_specifiers); fprintf(op, "%s", $1); }          
        | type_qualifier declaration_specifiers
                { print(declaration_specifiers); fprintf(op, "%s %s", $1, $2); }                 
        ;

init_declarator_list
        : init_declarator
                        { print(init_declarator_list); /*$$ = strdup(yytext);*/ }
        | init_declarator_list ',' init_declarator
                        { print(init_declarator_list);	
				fprintf(op, "%s, %s", $1, $3); }
        ;               

init_declarator
        : declarator
                        { print(init_declarator); /* $$ = strdup(yytext); */ }              
        | declarator '=' initializer { print(init_declarator); }
                        { print(init_declarator);
				sprintf($$, "%s = %s", $1, $3); }                           
        ;

storage_class_specifier
        : GLOBAL { print(storage_class_specifier); $$ = strdup(yytext); }   
        ;

type_specifier
	: NONE { print(type_specifier); $$ = strdup(yytext); 
					strcpy(type, "void"); }
        | STRING { print(type_specifier); $$ = strdup(yytext);
					strcpy(type, "string"); }
        | BOOLEAN { print(type_specifier); $$ = strdup(yytext);
					strcpy(type, "bool"); }
        | NUMBER { print(type_specifier); $$ = strdup("long double");
					strcpy(type, "long double"); }
        | CARD { print(type_specifier); $$ = strdup(yytext);
					strcpy(type, "Card"); }
        | PLAYER { print(type_specifier); $$ = strdup(yytext);
					strcpy(type, "Player"); }
        | PILE { print(type_specifier); $$ = strdup(yytext);
					strcpy(type, "Pile"); }
        | RANK { print(type_specifier); $$ = strdup(yytext);
					strcpy(type, "Rank"); }
	| GAME { print(type_specifier); $$ = strdup(yytext);
					strcpy(type, "Game"); }
	| attribute_specifier { print(type_specifier); $$ = $1; }
	| record_specifier { print(type_specifier); }
        | catalog_specifier { print(type_specifier); }
        ;

game_element
	: SETUP { print(game_element); $$ = strdup(yytext); }
	| ROUND { print(game_element); $$ = strdup(yytext); }
	;

attribute_specifier
	: ATTRIBUTE identifier '{' attribute_value_list '}' { print(attribute_specifier);
							$$ = strdup(yytext); 
							sprintf($$, "enum %s { %s }", $2, $4); }
	;

attribute_value_list
	: attribute_constant { print(attribute_value_list);
							$$ = strdup(yytext); 
							sprintf($$, "%s", $1); }
	| attribute_value_list ',' attribute_constant { print(attribute_value_list);
							$$ = malloc(sizeof(char) * strlen($1) + strlen($3) + 1/*comma*/
												 + 1/*space*/ + 1/*NUL*/ );
							// Check memalloc fail.
							sprintf($$, "%s, %s", $1, $3); }

	;

attribute_constant
	: constant_expression { print(attribute_constant); sprintf($$, "%s", $1); }
	;

record_specifier
        : RECORD identifier '{' record_declaration_list '}'
        { print(record_specifier); fprintf(op, "struct %s { %s }", $2, $4); }
	| RECORD identifier
	{ print(record_specifier); fprintf(op, "struct %s", $2); }
        ;

record_declaration_list
        : record_declaration { print(record_declaration_list);
				fprintf(op, "%s", $1); }                                      
        | record_declaration_list record_declaration
          { print(record_declaration_list); fprintf(op, "%s %s", $1, $2); }                              
        ;

record_declaration
        : specifier_qualifier_list record_declarator_list ';'
          { print(record_declaration); fprintf(op, "%s %s;", $1, $2); }             
        ;

specifier_qualifier_list
        : type_specifier specifier_qualifier_list
          { print(specifier_qualifier_list); /*fprintf(op, "%s %s", $1, $2); */ }                               
        | type_specifier
          { print(specifier_qualifier_list); /* fprintf(op, "%s", $1); */ $$ = strdup(yytext); }                          
        | type_qualifier specifier_qualifier_list
          { print(specifier_qualifier_list); /* fprintf(op, "%s %s", $1, $2); */ }                                 
        | type_qualifier
          { print(specifier_qualifier_list); /* fprintf(op, "%s", $1); */ $$ = strdup(yytext); }                          
        ;

record_declarator_list
        : record_declarator
          { print(record_declarator); fprintf(op, "%s", $1); }                                  
        | record_declarator_list ',' record_declarator
          { print(record_declarator); fprintf(op, "%s, %s", $1, $3); }                                         
        ;

record_declarator
        : declarator { print(record_declarator); fprintf(op, "%s", $1); }
        ;

catalog_specifier
        : CATALOG '{' catalog_list '}' { print(catalog_specifier); fprintf(op, "enum { %s }", $3); }
        | CATALOG identifier '{' catalog_list '}' { print(catalog_specifier); fprintf(op, "enum %s { %s }", $2, $4); }
	| CATALOG identifier { fprintf(op, "enum %s", $2); }
        ; 

catalog_list
        : catalog_constant { print(catalog_list); fprintf(op, "%s", $1); }    
        | catalog_list ',' catalog_constant { print(catalog_list); fprintf(op, "%s, %s", $1, $3); }
        ;

catalog_constant
        : identifier { print(catalog_constant); }
        | identifier '=' constant_expression { print(catalog_constant); fprintf(op, "%s = %s", $1, $3); }    
        ;

type_qualifier
        : CONST { print(attribute_or_record_declarator); $$ = strdup(yytext); }    
        ;

declarator
        : identifier { print(declarator); printf("declarator: %s\n", yytext); }
        | '(' declarator ')' { print(declarator); fprintf(op, "(%s)", $2); }
        | declarator '(' parameter_type_list ')' { print(declarator); fprintf(op, "%s %s(%s)", type, $1, $3); }
        | declarator '(' identifier_list ')' { print(declarator); fprintf(op, "%s(%s)", $1, $3); }
        | declarator '(' ')' { print(declarator); fprintf(op, "%s()", $1); }
        ;


parameter_type_list
        : parameter_list { print(parameter_type_list); /* fprintf(op, "%s", $1); */ }
        ;

parameter_list
        : parameter_declaration { print(parameter_list); /* $$ = strdup(yytext); *//* fprintf(op, "%s", $1); */ }
        | parameter_list ',' parameter_declaration { print(parameter_list); fprintf(op, "%s, %s", $1, $3); }
        ;


parameter_declaration
        : declaration_specifiers declarator { print(parameter_declaration); sprintf($$, "%s %s", $1, $2); }
	| declaration_specifiers { print(parameter_declaration); $$ = strdup(yytext); fprintf(op, "%s", $1); }
        ;

identifier_list
        : identifier { print(identifier_list); }    
        | identifier_list ',' identifier { print(identifier_list); fprintf(op, "%s, %s", $1, $3); }
        ;

initializer
        : assignment_expression { print(initializer); }
        | '{' initializer_list '}' { print(initializer); fprintf(op, "{ %s }", $2); }
        ;

initializer_list
        : initializer { print(initializer_list); fprintf(op, "%s", $1); }
        | initializer_list ',' initializer { print(initializer_list); fprintf(op, "%s, %s", $1, $3); }  
        ;

statement
        : labeled_statement { print(statement); fprintf(op, "%s", $1);  }
        | expression_statement { print(statement); }
        | block_statement { print(statement);     /* fprintf(op, "%s", $1);*/ }
        | selection_statement { print(statement); /* fprintf(op, "%s", $1); */ }
        | iteration_statement { print(statement); /* fprintf(op, "%s", $1); */ }
        | jump_statement { print(statement); /* fprintf(op, "%s", $1); */ }
        ;

labeled_statement
        : CASE constant_expression ':' statement { print(labeled_statement); $$ = strdup(yytext); fseek(op, -(strlen($4) + 1), SEEK_CUR); sprintf($$, "case %s : %s;\n break;\n", $2, $4); }
        | DEFAULT ':' statement { print(labeled_statement); fprintf(op, "default : %s break;\n", $3); }   
        ;

expression_statement
        : ';' { print(expression_statement); fprintf(op, ";"); }    
        | expression ';' { print(expression_statement); /* sprintf($$, "%s;", $1); */ fprintf(op, "%s;", $1); }    
        ;

block_statement
	: '{' declaration_list_or_statement_list '}' { print(block_statement); /* fprintf(op, "{ %s }", $2); */ } 
	| game_element '{' declaration_list_or_statement_list '}' { print(block_statement); /*fprintf(op, "%s { %s }", $1, $3); */ }
        | '{' '}' { print(block_statement); fprintf(op, "{}"); }
        | game_element '{' '}' { print(block_statement); fprintf(op, "%s {}", $1); }
        ;

declaration_list_or_statement_list
        : declaration { print(declaration_list); /* printf("%s", $1); */ }
        | declaration_list_or_statement_list declaration { print(declaration_list); /* fprintf(op, "%s %s", $1, $2); */ }
        | statement { print(statement_list); $$ = $1; }
        | declaration_list_or_statement_list statement { print(statement_list); /* fprintf(op, "%s %s", $1, $2); */ }
        ;

selection_statement
        : IF '(' expression ')' statement { print(selection_statement); /* fprintf(op, "if ( %s ) %s", $3, $5); */ }
        | IF '(' expression ')' statement ELSE statement { print(selection_statement); /* fprintf(op, "if ( %s ) %s else %s", $3, $5, $7); */ }
        | SWITCH '(' expression ')' statement { print(selection_statement); /* fprintf(op, "switch ( %s ) %s", $3, $5); */ }
        ;


iteration_statement
        : REPEAT statement UNTIL '(' expression ')' ';' { print(iteration_statement); /* fprintf(op, "do %s while ( %s );", $2, $5); */ }
        | FOREACH identifier statement { print(iteration_statement); fprintf(op, "foreach %s %s", $2, $3); }
        | FOREACH identifier IN identifier statement { print(iteration_statement); /* fprintf(op, "foreach %s in %s %s", $2, $4, $5); */ }
	| LOOP identifier IN constant_expression statement { print(iteration_statement); /* fprintf(op, "loop %s in %s %s", $2, $4, $5);*/ }
        | LOOP constant_expression statement { print(iteration_statement); fprintf(op, "while ( %s ) %s", $2, $3); }
        ;

jump_statement
        : LOOPBACK ';' { print(jump_statement); fprintf(op, "continue;"); }
        | FALLTHROUGH ';' { print(jump_statement); }
        | BREAK ';' { print(jump_statement); fprintf(op, "break;"); }
        | RETURN expression ';' { print(jump_statement); fprintf(op, "return %s;", $2); }
        | RETURN ';' { print(jump_statement); fprintf(op, "return;"); }
        ;

        
translation_unit
        : elements { print(translation_unit); }
        | translation_unit elements { print(translation_unit); }
        ;

elements
        : function_definition { print(elements); }    
        | procedure_definition { print(elements); }
        | declaration { print(elements); }
        ;

function_definition
        : declaration_specifiers declarator block_statement { print(function_definition); /* fprintf(op, "%s %s \n%s", $1, $2, $3); */ }    
        ;  

procedure_definition
        : identifier block_statement { print(procedure_definition); }    
        ;   

%%

char type[ 1000 ] = "";

#include "../lexer/lex.yy.c"

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    printf("Compile-time error(Unrecognized pattern - without outermost quotes) %llu: "
							"\"%s\"\n", SrcLineNum, yytext);
    exit(0);
    return 0;
}


int yywrap(void)
{
    return 0;
}

void display(char *s, int line)
{
        printf("%s : %d\n", s, line);
}

