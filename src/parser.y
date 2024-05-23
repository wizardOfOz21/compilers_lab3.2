%{
    #include <stdio.h>
    #include <string.h>
    #include "lexer.h"
%}

%define api.pure
%locations
%lex-param {yyscan_t scanner}  /* параметр для yylex() */
/* параметры для yyparse() */
%parse-param {yyscan_t scanner}
%parse-param {long env[26]}

%union {
    char variable;
    long number;
}

%token LPAREN
%token RPAREN
%token COMMA;
%token POINTS
%token CARET;
%token PLUS;
%token MINUS;
%token LBRACKET;
%token RBRACKET;
%token EQUAL;
%token COLON;
%token SEMICOLON;

%token NIL PACKED OF ARRAY FILE_ SET RECORD END TYPE VAR CASE CONST

%union {
    char* string;
}

%token <string> IDENTIFIER;
%token <string> UNSIGNED_NUMBER;
%token <string> STRING;
%token <string> COMMENT;

%{
int yylex(YYSTYPE *yylval_param, YYLTYPE *yylloc_param, yyscan_t scanner);
void yyerror(YYLTYPE *loc, yyscan_t scanner, long env[26], const char *message);
%}

%%

program: program block | block | record_type
    ;

block: type_block | constant_block
    ;

/* Определение константы */

constant_block: CONST constant_definition_list semicolon
    ;

constant_definition_list: constant_definition_list SEMICOLON constant_definition | constant_definition
    ;

constant_definition: IDENTIFIER EQUAL constant
    ;

unsigned_constant: UNSIGNED_NUMBER | STRING | NIL | constant_ident
    ;

constant: sign unsigned_constant_number | unsigned_constant_number | STRING
    ;

unsigned_constant_number: UNSIGNED_NUMBER | constant_ident
    ;

constant_ident: IDENTIFIER {print("constant_ident")}

sign: PLUS | MINUS
    ;

/* sing_: / пусто / | sign  почему-то не работает в начале правила 
    ; */

/* Определение константы */

/* Определение типа */
type_block: TYPE type_definition_list semicolon
    ;

type_definition_list: type_definition_list SEMICOLON type_definition | type_definition
    ;

type_definition: IDENTIFIER EQUAL type
    ;

type: simple_type | pointer_type | structured_type
    ;

simple_type: scalar_type | subrange_type | type_ident
    ;

scalar_type: LPAREN ident_list RPAREN
    ;

ident_list: ident_list COMMA IDENTIFIER | IDENTIFIER
    ;

subrange_type: constant POINTS constant
    ;

structured_type: PACKED unpacked_structured_type | unpacked_structured_type
    ;

unpacked_structured_type: array_type | record_type | file_type | set_type
    ;

array_type: ARRAY LBRACKET index_type_list RBRACKET OF component_type
    ;

index_type_list: index_type_list COMMA index_type | index_type
    ;

index_type: simple_type
    ;

component_type: type
    ;

/*  Тип записи */

record_type: RECORD field_list END {print("record_type")}
    ;

field_list: fixed_part | fixed_part SEMICOLON variant_part | variant_part
    ;

fixed_part: fixed_part SEMICOLON record_section | record_section {print("fixed_part")}
    ;

record_section: field_ident_list {print("field_ident_list")} COLON type
    ;

field_ident_list: field_ident_list COMMA field_ident | field_ident
    ;

variant_part: CASE tag_field COLON type_ident OF variant_list {print("variant_part")}
    ;

variant_list: variant_list SEMICOLON variant | variant
    ;

variant: case_label_list COLON LPAREN field_list RPAREN | case_label_list
    ;

case_label_list: case_label_list COMMA case_label | case_label
    ;

/*  Тип записи */

set_type: SET OF base_type
    ;

base_type: simple_type
    ;

file_type: FILE_ OF type
    ;

pointer_type: CARET type_ident
    ;

case_label: unsigned_constant
    ;

tag_field: IDENTIFIER
    ;

field_ident: IDENTIFIER
    ;

type_ident: IDENTIFIER
    ;

semicolon: /* пусто */ {print("semicolon_false")} 
    | SEMICOLON {print("semicolon_true")}
    ;

/* Определение типа */


%%

int main(int argc, char *argv[]) {
    FILE *input = 0;
    long env[26] = { 0 };
    yyscan_t scanner;
    struct Extra extra;

    if (argc > 1) {
        input = fopen(argv[1], "r");
    } else {
        printf("No file in command line, use stdin\n");
        input = stdin;
    }

    bool is_dev = false;

    if (argc > 2 && !strcmp(argv[2], "dev")) {
        is_dev = true;
    }

    init_scanner(input, &scanner, &extra, is_dev);
    yyparse(scanner, env);
    destroy_scanner(scanner);

    if (input != stdin) {
        fclose(input);
    }

    return 0;
}