#ifndef LEXER_H
#define LEXER_H

#include <stdbool.h>
#include <stdio.h>

#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void *yyscan_t;
#endif /* YY_TYPEDEF_YY_SCANNER_T */

#define MAX_STRING_LENGTH 1000

#define NEWLINE 0
#define TAB 1
#define SLASH 2
#define QUOTE 3

char spec_symbols_prod[];
char spec_symbols_dev[];

struct Extra {
    bool continued;
    char* spec_symbols;
    int string_index;
    int cur_line;
    int cur_column;
};

void init_scanner(FILE *input, yyscan_t *scanner, struct Extra *extra, bool is_dev);
void destroy_scanner(yyscan_t);

#endif /* LEXER_H */

// * [ ] ( ) " \ { } специальные символы, требующие экранирования