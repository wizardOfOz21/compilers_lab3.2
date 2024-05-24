%{
    #include <stdio.h>
    #include <string.h>
    #include "lexer.h"
    #include "config.h"
    #include "format.h"
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

%token <string> NIL 
%token <string> PACKED 
%token <string> OF 
%token <string> ARRAY 
%token <string> FILE_ 
%token <string> SET 
%token <string> RECORD 
%token <string> END 
%token <string> VAR 
%token <string> CASE 
%token <string> CONST
%token <string> TYPE

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

%%

program: blocks { ns }
    ;

blocks: blocks { ns } block | block 
    ;

block: type_block | constant_block
    ;

/* Определение константы */

constant_block: const_ { nd } constant_definition_list possible_semicolon { dec }
    ;

constant_definition_list: constant_definition_list _semicolon_ { ns } constant_definition | constant_definition
    ;

constant_definition: _ident_ { s } _equal_ { s } constant
    ;

constant: sign unsigned_constant_number | unsigned_constant_number | _string_
    ;

unsigned_constant_number: _unsigned_number_ | constant_ident
    ;

constant_ident: _ident_

sign: _plus_ | _minus_
    ;

/* sing_: / пусто / | sign  почему-то не работает в начале правила 
    ; */

/* Определение константы */

/* Определение типа */
type_block: _type_ { nd } type_definition_list possible_semicolon { dec }
    ;

type_definition_list: type_definition_list _semicolon_ { ns } type_definition | type_definition
    ;

type_definition: _ident_ { s } _equal_ { s } type
    ;

type: simple_type | pointer_type | structured_type
    ;

simple_type: scalar_type | subrange_type | type_ident
    ;

scalar_type: _lparen_ ident_list _rparen_
    ;

ident_list: ident_list _comma_ { s } _ident_ | _ident_
    ;

subrange_type: constant { s } _points_ { s } constant
    ;

structured_type: _packed_ { s } unpacked_structured_type | unpacked_structured_type
    ;

unpacked_structured_type: array_type | record_type | file_type | set_type
    ;

array_type: _array_ { s } _lbracket_ index_type_list _rbracket_ { s } _of_ { s } component_type
    ;

index_type_list: index_type_list _comma_ { s } index_type | index_type
    ;

index_type: simple_type
    ;

component_type: type
    ;

/*  Тип записи */

record_type: _record_ { nd } field_list { nu } _end_
    ;

field_list: fixed_part | fixed_part _semicolon_ { ns } variant_part | variant_part
    ;

fixed_part: fixed_part _semicolon_ { ns } record_section | record_section
    ;

record_section: field_ident_list _colon_ { s } type
    ;

field_ident_list: field_ident_list _comma_ { s } field_ident | field_ident
    ;

field_ident: _ident_
    ;

variant_part: _case_ { s } tag_field { s } _colon_ { s } type_ident {s} _of_ { nd } variant_list { dec }
    ;

variant_list: variant_list _semicolon_ { ns } variant | variant
    ;

variant: case_label_list _colon_ { s } _lparen_ { nd } field_list { nu } _rparen_ | case_label_list
    ;

case_label_list: case_label_list _comma_ { s } case_label | case_label
    ;

case_label: unsigned_constant
    ;

unsigned_constant: _unsigned_number_ | _string_ | _nil_ | constant_ident
    ;

/*  Тип записи */

set_type: _set_ { s } _of_ { s } base_type
    ;

base_type: simple_type
    ;

file_type: _file_ { s } _of_ { s } base_type  type
    ;

pointer_type: _caret_ type_ident
    ;

tag_field: _ident_
    ;

type_ident: _ident_
    ;

/* Определение типа */

_ident_: IDENTIFIER { p($1) } { f($1) }
    ;

_string_: STRING { p($1) } { f($1) }
    ;

_unsigned_number_: UNSIGNED_NUMBER { p($1)} { f($1) } 
    ;

/* Ключевые слова */

_type_: TYPE { alt($1, TYPE_TEMP) } { f($1) }
    ;

const_: CONST { alt($1, CONST_TEMP) } { f($1) }
    ;

_packed_: PACKED { alt($1, PACKED_TEMP) } { f($1) }
    ;

_array_: ARRAY { alt($1, ARRAY_TEMP) } { f($1) }
    ;

_of_: OF { alt($1, OF_TEMP) } { f($1) }
    ;

_record_: RECORD { alt($1, RECORD_TEMP) } { f($1) }
    ;

_end_: END { alt($1, END_TEMP) } { f($1) }
    ;

_case_: CASE { alt($1, CASE_TEMP) } { f($1) }
    ;

_nil_: NIL { alt($1, NIL_TEMP) } { f($1) }
    ;

_set_: SET { alt($1, SET_TEMP) } { f($1) }
    ;

_file_: FILE_ { alt($1, FILE_TEMP) } { f($1) }
    ;

/* Ключевые слова */

_semicolon_: SEMICOLON { p(";") }
    ;

possible_semicolon: /* пусто */ { !WEAK && p(";") }    {trace("semicolon_false")}
    | _semicolon_                                       {trace("semicolon_true")}
    ;

_equal_: EQUAL { p("=") }
    ;

_plus_: PLUS { p("+") }
    ;

_minus_: MINUS { p("-") }
    ;

_lparen_: LPAREN { p("(") }
    ;

_rparen_: RPAREN { p(")") }
    ;

_comma_: COMMA { p(",") }
    ;

_points_: POINTS { p("..") }
    ;

_lbracket_: LBRACKET { p("[") }
    ;

_rbracket_: RBRACKET { p("]") }
    ;

_colon_: COLON { p(":") }
    ;

_caret_: CARET { p("^") }
    ;

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
    KEYWORDS_FORMAT = 1;

    char* arg;
    for (int i = 0; i < argc; ++i) {
        arg = argv[i];
        if (!strcmp(arg, "dev")) {
            is_dev = true;
        }
        if (!strcmp(arg, "-k")) {
            KEYWORDS_FORMAT = 0;
        }
        if (!strcmp(arg, "-w")) {
            WEAK = 1;
        }
    }

    init_scanner(input, &scanner, &extra, is_dev);
    yyparse(scanner, env);
    destroy_scanner(scanner);

    if (input != stdin) {
        fclose(input);
    }

    return 0;
}
