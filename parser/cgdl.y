%{
%}
%token ADD SUB MUL DIV MOD 
%token GRT GE LES LE EQ NE 
%token ASS UMINUS NOT REFERENCE
%token SEMI COLON COMMA
%token AND OR XOR TRUE FALSE
%token BOOL CATALOG ID CONSTANT RECORD NONE NUMBER STRING LITERAL
%token CONST GLOBAL
%token FOR EACH IS IN REPEAT UNTIL LOOP LOOPBACK ENDLOOP LOOKUP UNKNOWN KEY QUES
%token IF THEN ELSE
%token RETURN
%%

translation_unit: elements
                | translation_unit elements
                ;

elements: function_definition
        | procedure_definition
        | declaration
        ;

function_definition: declaration_specifiers  declarator block_statement
                    ;  

procedure_definition: ID block_statement
                    ;   

primary_expression: ID
                    | constant
                    | string_literal
                    | '('expression')'
                    ;

constant: NUMBER
        | catalog_constant
        | boolean_constant
        ;

boolean_constant: TRUE
                | FALSE
                ;

string_literal: '\"'LITERAL'\"'
                ;

postfix_expression: primary_expression
                  | postfix_expression'[' expression ']'
                  | postfix_expression'('argument_expression_list')'
                  | postfix_expression'(' ')'
                  | postfix_expression '.' ID /* is dot inside quote ? */
                  ;

argument_expression_list: assignment_expression
                        | argument_expression_list COMMA assignment_expression
                        ;

unary_expression: unary_operator expression
                ;

unary_operator: UMINUS
                | REFERENCE
                | NOT
                ;

multiplicative_expression: postfix_expression
                        | multiplicative_expression MUL expression
                        | multiplicative_expression DIV expression
                        | multiplicative_expression MOD expression
                        ;

additive_expression: multiplicative_expression
                    | additive_expression ADD multiplicative_expression
                    | additive_expression SUB multiplicative_expression
                    ;

relational_expression: additive_expression
                    | relational_expression GRT additive_expression
                    | relational_expression LES additive_expression
                    | relational_expression GE additive_expression
                    | relational_expression LE additive_expression
                    ;

equality_expression: relational_expression
                    | equality_expression EQ relational_expression
                    | equality_expression NE relational_expression
                    ;

logical_AND_expression: equality_expression
                    | logical_AND_expression AND equality_expression
                    ;

logical_OR_expression: logical_AND_expression
                    | logical_OR_expression OR logical_AND_expression
                    ;

logical_XOR_expression: logical_OR_expression
                    | logical_XOR_expression XOR logical_XOR_expression  
                    ;

expression: assignment_expression
          | expression COMMA assignment_expression
          ;

assignment_expression: logical_XOR_expression
                    | unary_expression ASS assignment_expression
                    ;
    
constant_expression: logical_XOR_expression
                    ;

declaration: declaration_specifiers declarator_list
                    ;

declaration_specifiers: storage_class_specifier declaration_specifiers
                    | storage_class_specifier
                    | type_specifier declaration_specifiers
                    | type_specifier
                    | qualifier declaration_specifiers
                    | qualifier
                    ;

declarator_list: declarator
                | declarator_list
                ;

storage_class_specifier: GLOBAL

type_specifier: NONE
                | STRING
                | BOOL
                | NUMBER
                | record_specifier
                | catalog_specifier
                | suit_specifier
                ;

qualifier: CONST
        ;

record_specifier: RECORD ID '{' record_declaration_list '}'
                | RECORD ID
                ;

record_declaration_list: RECORD declaration
                        | record_declaration_list RECORD declaration
                        ;

record_declaration: specifier_qualifier_list record_declarator_list SEMI 
                    ;

specifier_qualifier_list: type_specifier specifier_qualifier_list
                        | type_specifier
                        ;

record_declarator_list: declarator
                    | record_declarator_list COMMA declarator
                    ;

record_specifier: RECORD ID '{' record_declaration_list '}'
                | RECORD ID
                ;

catalog_specifier: CATALOG ID '{' catalog_list '}'
                | CATALOG '{' catalog_list '}'
                | CATALOG ID
                ;

catalog_list: catalog_constant
            | catalog_list COMMA catalog_constant
            ;

catalog_constant: ID
                | ID ASS constant expression
                ;

declarator: ID
          | declarator '[' constant_expression ']'
          | declarator '[' ']'
          | declarator '(' parameter_type_list ')'
          | declarator '(' identifier_list ')'
          | declarator '(' ')'
          ;

identifier_list: ID
                | identifier_list COMMA ID
                ;

parameter_type_list: parameter_list 
                    ;

parameter_list: parameter_declaration
                | parameter_list COMMA parameter_declaration
                ;

parameter_declaration: declaration_specifiers declarator
                    ;

initializer: assignment_expression
            | '{' initializer_list '}'
            ;

initializer_list: initializer
                | initializer_list COMMA initializer
                ;

suit_identifier: ID
                ;

suit_specifier: suit_identifier '{' suit_declaration_list '}'
                | suit_identifier
                ;

suit_declaration_list: suit_declaration
                    | suit_declaration_list COMMA suit_declaration SEMI
                    ;

suit_declaration: suit_identifier COLON  constant_expression
                ;

statement: labeled_statement
        | expression_statement
        | block_statement
        | selection_statement
        | iteration_statement
        | jump_statement
        ;

labeled_statement: KEY constant_expression QUES statement
                | UNKNOWN QUES statement
                ;

expression_statement: expression SEMI
                    | SEMI
                    ;

block_statement: '{' declaration_list   statement_list '}'
                | '{' declaration_list '}'
                | '{' statement_list '}'
                | '{' '}'
                ;

declaration_list: declaration
                | declaration_list declaration
                ;

statement_list: statement
            | statement_list statement
            ;

selection_statement: IF '(' expression ')' THEN statement
                    | IF '(' expression ')' THEN statement ELSE statement
                    | LOOKUP '(' expression ')' statement
                    ;

iteration_statement: REPEAT statement UNTIL '(' expression ')'
                    | FOR EACH ID statement
                    | FOR EACH ID IN ID statement
                    | LOOP constant_expression statement
                    ;

jump_statement: LOOPBACK SEMI
                | ENDLOOP SEMI
                | RETURN expression /*;*/
                | RETURN SEMI
                ;
%%

