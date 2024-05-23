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

program: list
    ;

list: list COMMA statement { printf("\n"); } | statement { printf("\n"); }
    ;

statement: IDENTIFIER  { printf($IDENTIFIER); } | UNSIGNED_NUMBER { printf($UNSIGNED_NUMBER); } | STRING { printf($STRING); }
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