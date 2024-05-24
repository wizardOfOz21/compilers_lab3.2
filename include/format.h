#ifndef FORMAT_H
#define FORMAT_H

#define margin()                     \
    for (int i = 0; i < env[0]; ++i) \
        printf("\t");

#define inc env[0]++;

#define dec env[0]--;

#define n printf("\n");

#define s printf(" ");

#define m margin();

#define nd inc n m; // \n down
#define nu dec n m; // \n up
#define ns n m;     // \n straight

#define p(str) \
    printf("%s", str);

#define alt(str, temp) printf("%s", env[1] ? temp : str);

#define f(arg) free(arg);

#define TYPE_TEMP       "Type"
#define NIL_TEMP        "Nil"
#define PACKED_TEMP     "Packed"
#define OF_TEMP         "Of"
#define ARRAY_TEMP      "Array"
#define FILE_TEMP       "File"
#define SET_TEMP        "Set"
#define RECORD_TEMP     "Record"
#define END_TEMP        "End"
#define VAR_TEMP        "Var"
#define CASE_TEMP       "Case"
#define CONST_TEMP      "Const"
#define TYPE_TEMP       "Type"

#endif /* FORMAT_H */