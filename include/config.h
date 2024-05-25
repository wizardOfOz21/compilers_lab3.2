#ifndef CONFIG_H
#define CONFIG_H

#define DEBUG false  //  трассировка

#define MARGIN              env[0]
#define KEYWORDS_FORMAT     env[1]
#define WEAK                env[2]
#define DEV_MODE            env[3]

#define trace(str) DEBUG && printf("%s\n", str);

#define MAX_STRING_LENGTH 1000

#endif /* CONFIG_H */