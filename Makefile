TESTS = $(shell ls test/*)
SRC_DIR 		= src
BUILD_DIR 		= build
INCLUDE_DIR 	= include
PARSER_SRC 		= ${SRC_DIR}/parser.y
LEXER_SRC 		= ${SRC_DIR}/lexer.l
LEXER_OUT 		= ${BUILD_DIR}/lex.yy.c
PARSER_OUT_H	= ${BUILD_DIR}/y.tab.h
PARSER_OUT		= ${BUILD_DIR}/y.tab.c
PROG			= ${BUILD_DIR}/prog
TEST_N			= ${TEST_DIR}/test_${n}

TEST_DIR 		= test

build: flex bison gcc

flex: ${LEXER_SRC} 
	flex  -o${LEXER_OUT} ${LEXER_SRC}

bison: ${PARSER_SRC}
	bison ${PARSER_SRC} -H${PARSER_OUT_H} -o${PARSER_OUT} -Wconflicts-sr -Wconflicts-rr -Wcounterexamples;

gcc: ${LEXER_OUT} ${PARSER_OUT} ${PARSER_OUT_H}
	gcc -o ${PROG} ${BUILD_DIR}/*.c -I${BUILD_DIR} -I${INCLUDE_DIR} -w

run: input
	./${PROG} input ${ARGS}

crun: build run

tests:
	./${PROG} ${TEST_N} ${ARGS} > out

ctests: build tests

# make ctests n=1 – запуск теста 1
# make crun – запуск на файле input
# -k – выравнивать регистр ключевых слов
# -w – слабый форматтер
