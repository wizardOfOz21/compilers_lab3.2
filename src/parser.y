%{
    #include <stdio.h>
    #include <string.h>
    #include "lexer.h"

    #define margin() for (int i = 0; i < env[0]; ++i) printf("\t");

    #define inc env[0]++;

    #define dec env[0]--;

    #define n printf("\n");

    #define s printf(" ");

    #define m margin();

    #define nd inc n m; // \n down
    #define nu dec n m; // \n up
    #define ns n m;     // \n straight

    #define p(str) \
        printf("%s", str); \
    
    #define f(arg) free(arg);
        
%}

%define api.pure
%locations
%lex-param {yyscan_t scanner}  /* параметр для yylex() */
/* параметры для yyparse() */
%parse-param {yyscan_t scanner}
%parse-param {long env[26]}

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
    int margin;
}

%token <string> IDENTIFIER;
%token <string> UNSIGNED_NUMBER;
%token <string> STRING;
%token <string> COMMENT;

%{
int yylex(YYSTYPE *yylval_param, YYLTYPE *yylloc_param, yyscan_t scanner);
void yyerror(YYLTYPE *loc, yyscan_t scanner, long env[26], const char *message);
%}

%type <string> constant
%type <string> constant_ident
%type <string> unsigned_constant_number
%type <string> sign
%type <string> ident_list

%%

program: blocks { ns }
    ;

blocks: blocks { ns } block | block 
    ;

block: type_block | constant_block
    ;

/* Определение константы */

constant_block: CONST { p("Const") nd } constant_definition_list semicolon { p(";") dec }
    ;

constant_definition_list: constant_definition_list SEMICOLON { p(";") ns } constant_definition | constant_definition
    ;

constant_definition: IDENTIFIER { p($1) } EQUAL { s p("=") s } constant { f($1) }
    ;

constant: sign unsigned_constant_number | unsigned_constant_number | STRING { p($1) } { f($1) }
    ;

unsigned_constant_number: UNSIGNED_NUMBER { p($1)} { f($1) } | constant_ident
    ;

constant_ident: IDENTIFIER { p($1)} { f($1)} { trace("constant_ident") }

sign: PLUS { p("+") } | MINUS { p("-") }
    ;

/* sing_: / пусто / | sign  почему-то не работает в начале правила 
    ; */

/* Определение константы */

/* Определение типа */
type_block: TYPE { p("Type") nd } type_definition_list semicolon { p(";") dec }
    ;

type_definition_list: type_definition_list SEMICOLON { p(";") ns } type_definition | type_definition
    ;

type_definition: IDENTIFIER { p($1) } EQUAL { s p("=") s } type { f($1) }
    ;

type: simple_type | pointer_type | structured_type
    ;

simple_type: scalar_type | subrange_type | type_ident
    ;

scalar_type: LPAREN { p("(") } ident_list RPAREN { p(")") }
    ;

ident_list: ident_list COMMA { p(",") s } IDENTIFIER { p($1) } { f($1) } | IDENTIFIER { p($1) } { f($1) }
    ;

subrange_type: constant POINTS { s p("..") s } constant
    ;

structured_type: PACKED { p("packed") s } unpacked_structured_type | unpacked_structured_type
    ;

unpacked_structured_type: array_type | record_type | file_type | set_type
    ;

array_type: ARRAY { p("array") s } LBRACKET { p("[") } index_type_list RBRACKET { p("]") } OF { s p("of") s } component_type
    ;

index_type_list: index_type_list COMMA { p(",") s } index_type | index_type
    ;

index_type: simple_type
    ;

component_type: type
    ;

/*  Тип записи */

record_type: RECORD { p("record") nd } field_list END { nu p("end") } {trace("record_type")}
    ;

field_list: fixed_part | fixed_part SEMICOLON { p(";") ns } variant_part | variant_part
    ;

fixed_part: fixed_part SEMICOLON { p(";") ns } record_section | record_section {trace("fixed_part")}
    ;

record_section: field_ident_list {trace("field_ident_list")} COLON { p(":") s } type
    ;

field_ident_list: field_ident_list COMMA { p(",") s } field_ident | field_ident
    ;

field_ident: IDENTIFIER { p($1) f($1) }
    ;

variant_part: CASE { p("case") s } tag_field COLON { s p(":") s } type_ident OF { s p("of") nd } variant_list {trace("variant_part")} { dec }
    ;

variant_list: variant_list SEMICOLON { p(";") ns } variant | variant
    ;

variant: case_label_list COLON LPAREN { p(": (") nd } field_list { nu } RPAREN { p(")") } | case_label_list
    ;

case_label_list: case_label_list COMMA { p(",") s } case_label | case_label
    ;

case_label: unsigned_constant
    ;

unsigned_constant: UNSIGNED_NUMBER { p($1) f($1) } | STRING { p($1) f($1) } | NIL { p("nil") } | constant_ident
    ;

/*  Тип записи */

set_type: SET OF { p("set of ") s } base_type
    ;

base_type: simple_type
    ;

file_type: FILE_ OF { p("file of ") s }  type
    ;

pointer_type: CARET { p("^") } type_ident
    ;

tag_field: IDENTIFIER { p($1) } { f($1) }
    ;

type_ident: IDENTIFIER { p($1) f($1) }
    ;

semicolon: %empty {trace("semicolon_false")}
    | SEMICOLON {trace("semicolon_true")}
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