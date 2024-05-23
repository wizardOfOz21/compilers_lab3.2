%option reentrant noyywrap bison-bridge bison-locations
%option extra-type="struct Extra *"

/* Подавление предупреждений для -Wall */
%option noinput nounput

%{

#include <stdio.h>
#include <stdlib.h>
#include "lexer.h"
#include "y.tab.h"  /* файл генерируется Bison’ом */

#define YY_USER_ACTION \
  { \
    int i; \
    struct Extra *extra = yyextra; \
    if (! extra->continued ) { \
      yylloc->first_line = extra->cur_line; \
      yylloc->first_column = extra->cur_column; \
    } \
    extra->continued = false; \
    for (i = 0; i < yyleng; ++i) { \
      if (yytext[i] == '\n') { \
        extra->cur_line += 1; \
        extra->cur_column = 1; \
      } else { \
        extra->cur_column += 1; \
      } \
    } \
    yylloc->last_line = extra->cur_line; \
    yylloc->last_column = extra->cur_column; \
}

void yyerror(YYLTYPE *loc, yyscan_t scanner, long env[26], const char *message) {
    printf("Error (%d,%d): %s\n", loc->first_line, loc->first_column, message);
}

void error(YYLTYPE *loc, yyscan_t scanner, const char *message) {
    printf("Error (%d,%d): %s\n", loc->first_line, loc->first_column, message);
}

char spec_symbols_prod[] = {
    '\n', '\t', '\\', '\'',
};

char spec_symbols_dev[] = {
    'N', 'T', '\\', '\'',
};

%}

%x STRING_STATE

%%

[\r\t\n ]+

\(      return LPAREN;
\)      return RPAREN;
,       return COMMA;
\.\.    {print(".."); return POINTS;};
\^      return CARET;
\+      return PLUS;
-       return MINUS;
\[      return LBRACKET;
\]      return RBRACKET;
=       {print(yytext); return EQUAL;};
:       return COLON;
;       return SEMICOLON;

[Nn][Ii][Ll]                return NIL;
[Pp][Aa][Cc][Kk][Ee][Dd]    return PACKED;
[Oo][Ff]                    return OF;
[Aa][Rr][Rr][Aa][Yy]        return ARRAY;
[Ff][Ii][Ll][Ee]            return FILE_;
[Ss][Ee][Tt]                return SET;
[Rr][Ee][Cc][Oo][Rr][Dd]    return RECORD;
[Ee][Nn][Dd]                return END;
[Tt][Yy][Pp][Ee]            return TYPE;
[Vv][Aa][Rr]                return VAR;
[Cc][Aa][Ss][Ee]            return CASE;
[Cc][Oo][Nn][Ss][Tt]        return CONST;

\(\*.*\\*\)       // TODO: оставлять в коде комментарии

[a-zA-Z]*                                { 
                                                yylval->string = yytext;
                                                print(yytext);
                                                return IDENTIFIER;
                                          };
[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?       { 
                                                yylval->string = yytext;
                                                return UNSIGNED_NUMBER;
                                          };

' {
    BEGIN(STRING_STATE);
    yyextra->continued=1;
    yyextra->string_index=0;
    yylval->string = (char*)malloc(MAX_STRING_LENGTH);
}

<STRING_STATE>\\n {
    yylval->string[yyextra->string_index++] = yyextra->spec_symbols[NEWLINE];
}

<STRING_STATE>\\t {
    yylval->string[yyextra->string_index++] = yyextra->spec_symbols[TAB];
}

<STRING_STATE>\\' {
    yylval->string[yyextra->string_index++] = yyextra->spec_symbols[QUOTE];
}

<STRING_STATE>\\\\ {
    yylval->string[yyextra->string_index++] = yyextra->spec_symbols[SLASH];
}

<STRING_STATE>[\n] {
    error(yylloc, yyscanner, "newline in string literal");
    return 0;
}

<STRING_STATE><<EOF>> {
    error(yylloc, yyscanner, "eof in string");
    return 0;
}

<STRING_STATE>[^'\\\n]* {
    int len = strlen(yytext);
    strncpy(&yylval->string[yyextra->string_index], yytext, len);
    yyextra->string_index += len;
    yyextra->continued = 1;
}

<STRING_STATE>' {
    BEGIN(0);
    return STRING;
}

%%

void init_scanner(FILE *input, yyscan_t *scanner, struct Extra *extra, bool is_dev) {
    extra->continued = false;
    extra->string_index = 0;
    extra->cur_line = 1;
    extra->cur_column = 1;
    if (is_dev) {
        extra->spec_symbols = spec_symbols_dev;
    } else {
        extra->spec_symbols = spec_symbols_prod;
    }

    yylex_init(scanner);
    yylex_init_extra(extra, scanner);
    yyset_in(input, *scanner);
}

void destroy_scanner(yyscan_t scanner) {
    yylex_destroy(scanner);
}
