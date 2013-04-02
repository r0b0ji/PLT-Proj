%{
#include <stdio.h>
#include <stdlib.h>

int yyerror(char *s);
void display(char *s, int line);

#define __DEBUG__

#ifdef __DEBUG__
	#define print(nt) display(#nt, __LINE__)
#else
	#define print(nt)
#endif

%}

%token ID STRING_LITERAL
%token LE_OP GE_OP EQ_OP NE_OP 
%token AND_OP OR_OP XOR_OP
%token GLOBAL
%token BOOLEAN NONE NUMBER STRING  RANK CARD PLAYER 
        DECK PILE CONST
%token CATALOG RECORD ATTRIBUTE
%token NUMBER_CONSTANT BOOLEAN_CONSTANT NULL_CONSTANT
%token FOREACH IN REPEAT UNTIL LOOP LOOPBACK ENDLOOP LOOKUP UNKNOWN KEY 
       FALLTHROUGH ENDLOOKUP IF THEN ELSE RETURN

%token UMINUS ALL NOONE SELF
%start lines


%%

lines
        : lines translation_unit '\n' { print(lines); }
        | lines '\n' { print(lines); }
        | /*empty*/ { print(lines); }
       

primary_expression
	    : ID { print(primary_expression); }
	    | NUMBER_CONSTANT { print(primary_expression); }
	    | BOOLEAN_CONSTANT { print(primary_expression); }
	    | NULL_CONSTANT { print(primary_expression); }
        | STRING_LITERAL { print(primary_expression); }
        | visibility_constant { print(primary_expression); }
        | '|' expression '|' { print(primary_expression); }
        ;

visibility_constant
        : ALL { print(visibility_constant); }
        | NOONE { print(visibility_constant); }
        | SELF { print(visibility_constant); }
        ;

postfix_expression
        : primary_expression { print(postfix_expression); }
        | postfix_expression '[' expression ']' { print(postfix_expression); }
        | postfix_expression '[' expression ':' expression ']' 
                                                { print(postfix_expression); }
	    | postfix_expression '(' ')' { print(postfix_expression); }
        | postfix_expression '(' argument_expression_list ')'
                                     { print(postfix_expression); }                     
        | postfix_expression '.' ID { print(postfix_expression); }
        ;


argument_expression_list
        : assignment_expression { print(argument_expression_list); }
        | argument_expression_list ',' assignment_expression
                                { print(argument_expression_list); }   
        ;

unary_expression
	: postfix_expression { print(unary_expression); }
        | unary_operator unary_expression { print(unary_expression); }
        ;

unary_operator
        : '@' { print(unary_expression); }
        | UMINUS { print(unary_expression); }
        | '!' { print(unary_expression); }
        ;

multiplicative_expression
        : unary_expression { print(multiplicative_expression); }
        | multiplicative_expression '*' unary_expression
        { print(multiplicative_expression); }
        | multiplicative_expression '/' unary_expression
        { print(multiplicative_expression); }
        | multiplicative_expression '%' unary_expression
        { print(multiplicative_expression); }
        ;

additive_expression
        : multiplicative_expression { print(additive_expression); }
        | additive_expression '+' multiplicative_expression
          { print(additive_expression); }
        | additive_expression '-' multiplicative_expression
          { print(additive_expression); }
        ;


relational_expression
        : additive_expression { print(relational_expression); }
        | relational_expression '<' additive_expression
                { print(relational_expression); }
        | relational_expression '>' additive_expression
                { print(relational_expression); }
        | relational_expression LE_OP additive_expression
                { print(relational_expression); }
        | relational_expression GE_OP additive_expression
                { print(relational_expression); }
        ;

equality_expression
        : relational_expression
                { print(equality_expression); }        
        | equality_expression EQ_OP relational_expression
                { print(equality_expression); }        
        | equality_expression NE_OP relational_expression
                { print(equality_expression); }        
        ;

logical_and_expression
        : equality_expression
                { print(logical_and_expression); }                
        | logical_and_expression AND_OP equality_expression
                { print(logical_and_expression); }                
        ;

logical_or_expression
        : logical_and_expression
                        { print(logical_or_expression); }        
        | logical_or_expression OR_OP logical_and_expression
                        { print(logical_or_expression); }        
        ;

logical_xor_expression
	    : logical_or_expression
                        { print(logical_xor_expression); }        	    
        | logical_xor_expression XOR_OP logical_or_expression
                        { print(logical_xor_expression); }                
        ;

assignment_expression
        : logical_xor_expression
                        { print(assignment_expression); }                        
        | unary_expression '=' assignment_expression
                        { print(assignment_expression); }                        
        ;

expression
        : assignment_expression
                        { print(expression); }                                
        | expression ',' assignment_expression
                        { print(expression); }                                
        ;

constant_expression
        : logical_xor_expression { print(constant_expression); }                        ;

declaration
        : declaration_specifiers ';' { print(declaration); }                                
        | declaration_specifiers init_declarator_list ';'
                { print(declaration); }                                
        ;

declaration_specifiers
        : storage_class_specifier
                { print(declaration_specifiers); }                                        
        | storage_class_specifier declaration_specifiers
                { print(declaration_specifiers); }                                        
        | type_specifier
                { print(declaration_specifiers); }                                        
        | type_specifier declaration_specifiers
                { print(declaration_specifiers); }                                        
        | type_qualifier
                { print(declaration_specifiers); }                                        
        | type_qualifier declaration_specifiers
                { print(declaration_specifiers); }                                        
        ;

init_declarator_list
        : init_declarator
                        { print(init_declarator_list); }                                
        | init_declarator_list ',' init_declarator
                        { print(init_declarator_list); }                                
        ;               

init_declarator
        : declarator
                        { print(init_declarator); }                                        
        | declarator '=' initializer { print(init_declarator); }
                        { print(init_declarator); }                                        
        ;

storage_class_specifier
        : GLOBAL { print(storage_class_specifier); }                                        
        ;

type_specifier
	    : NONE { print(type_specifier); }                                        
        | STRING { print(type_specifier); }                                         
        | BOOLEAN { print(type_specifier); }                                        
        | NUMBER { print(type_specifier); }                                        
        | CARD { print(type_specifier); }                                        
        | PLAYER { print(type_specifier); }                                         
        | DECK { print(type_specifier); }                                        
        | PILE { print(type_specifier); }                                        
        | RANK { print(type_specifier); }                                        
        | attribute_or_record_specifier { print(type_specifier); }                                        
        | catalog_specifier { print(type_specifier); }                                        
        ;

attribute_or_record_specifier
        : attribute_or_record ID '{' attribute_or_record_declaration_list '}'
        { print(attribute_or_record_specifier); }                                        
		| attribute_or_record ID
		{ print(attribute_or_record_specifier); }                                        
        ;
attribute_or_record
        : RECORD { print(attribute_or_record); }                                        
        | ATTRIBUTE { print(attribute_or_record); }                                        
        ;

attribute_or_record_declaration_list
        : attribute_or_record_declaration { print(attribute_or_record_declaration_list); }                                        
        | attribute_or_record_declaration_list attribute_or_record_declaration
          { print(attribute_or_record_declaration_list); }                                        
        ;

attribute_or_record_declaration
        : specifier_qualifier_list attribute_or_record_declarator_list ';'
          { print(attribute_or_record_declaration); }                                                
        ;

specifier_qualifier_list
        : type_specifier specifier_qualifier_list
          { print(specifier_qualifier_list); }                                                        
        | type_specifier
          { print(specifier_qualifier_list); }                                                        
        | type_qualifier specifier_qualifier_list
          { print(specifier_qualifier_list); }                                                        
        | type_qualifier
          { print(specifier_qualifier_list); }                                                        
        ;

attribute_or_record_declarator_list
        : attribute_or_record_declarator
          { print(attribute_or_record_declarator); }                                                                
        | attribute_or_record_declarator_list ',' attribute_or_record_declarator
          { print(attribute_or_record_declarator); }                                                                
        ;


attribute_or_record_declarator
        : declarator           { print(attribute_or_record_declarator); }    
        ;


catalog_specifier
        : CATALOG '{' catalog_list '}' { print(catalog_specifier); }    
        | CATALOG ID '{' catalog_list '}' { print(catalog_specifier); }    
        ; 

catalog_list
        : catalog_constant { print(catalog_list); }    
        | catalog_list ',' catalog_constant { print(catalog_list); }    
        ;

catalog_constant
        : ID { print(catalog_constant); }    
        | ID '=' constant_expression { print(catalog_constant); }    
        ;

type_qualifier
        : CONST { print(attribute_or_record_declarator); }    
        ;

declarator
        : ID { print(declarator); }    
        | '(' declarator ')' { print(declarator); }    
        | declarator '[' expression ']' { print(declarator); }    
        | declarator '[' ']' { print(declarator); }    
        | declarator '(' parameter_type_list ')' { print(declarator); }    
        | declarator '(' identifier_list ')' { print(declarator); }    
        | declarator '(' ')' { print(declarator); }    
        ;


parameter_type_list
        : parameter_list { print(parameter_type_list); }    
        ;

parameter_list
        : parameter_declaration { print(parameter_list); }    
        | parameter_list ',' parameter_declaration { print(parameter_list); }    
        ;


parameter_declaration
        : declaration_specifiers declarator { print(parameter_declaration); }    
        ;

identifier_list
        : ID { print(identifier_list); }    
        | identifier_list ',' ID { print(identifier_list); }    
        ;

initializer
        : assignment_expression { print(initializer); }    
        | '{' initializer_list '}' { print(initializer); }    
        ;

initializer_list
        : initializer { print(initializer_list); }    
        | initializer_list ',' initializer { print(initializer_list); }    
        ;

statement
        : labeled_statement { print(statement); }    
        | expression_statement { print(statement); }    
        | block_statement { print(statement); }    
        | selection_statement { print(statement); }    
        | iteration_statement { print(statement); }    
        | jump_statement { print(statement); }    
        ;
        
labeled_statement
        : KEY constant_expression '?' statement { print(labeled_statement); }    
        | UNKNOWN '?' statement { print(labeled_statement); }    
        ;

expression_statement
        : ';' { print(expression_statement); }    
        | expression ';' { print(expression_statement); }    
        ;

block_statement
	: '{' declaration_list_or_statement_list '}' { print(block_statement); } 
        | '{' '}' { print(block_statement); } 
        ;

declaration_list_or_statement_list
        : declaration { print(declaration_list); }
        | declaration_list_or_statement_list declaration { print(declaration_list); }
        | statement { print(statement_list); }    
        | declaration_list_or_statement_list statement { print(statement_list); }    
        ;

selection_statement
        : IF '(' expression ')' THEN statement { print(selection_statement); }    
        | IF '(' expression ')' THEN statement ELSE statement { print(selection_statement); }    
        | LOOKUP '(' expression ')' statement { print(selection_statement); }    
        ;


iteration_statement
        : REPEAT statement UNTIL '(' expression ')' ';' { print(iteration_statement); }    
        | FOREACH ID statement { print(iteration_statement); }    
        | FOREACH ID IN ID statement { print(iteration_statement); }    
        | LOOP constant_expression statement { print(iteration_statement); }    
        ;

jump_statement
        : LOOPBACK ';' { print(jump_statement); }    
        | FALLTHROUGH ';' { print(jump_statement); }    
        | ENDLOOP ';' { print(jump_statement); }    
        | ENDLOOKUP ';' { print(jump_statement); }    
        | RETURN expression ';' { print(jump_statement); }    
        | RETURN ';' { print(jump_statement); }    
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
        : declaration_specifiers declarator block_statement { print(function_definition); }    
        ;  

procedure_definition
        : ID block_statement { print(procedure_definition); }    
        ;   

%%

#include "../lexer/lex.yy.c"

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    printf("Compile-time error(Unrecognized pattern - without quotes): "
							"\"%s\"\n", yytext);
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
        return;
}

int main(void)
{
	yyparse();
	return 0;
}
                          
