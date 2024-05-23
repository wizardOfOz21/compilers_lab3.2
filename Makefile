TESTS = $(shell ls test/*)
SRC_DIR 	= src
INCLUDE_DIR = include
PARSER_SRC 	= ${SRC_DIR}/parser.y
LEXER_SRC 	= ${SRC_DIR}/lexer.l
BUILD_DIR 	= build
TEST_DIR 	= test

build: flex bison gcc

flex: ${LEXER_SRC} 
	flex  -o${BUILD_DIR}/lex.yy.c ${LEXER_SRC}

bison: ${PARSER_SRC}
	bison ${PARSER_SRC} -H${BUILD_DIR}/y.tab.h -o${BUILD_DIR}/y.tab.c;

gcc: ${BUILD_DIR}/lex.yy.c ${BUILD_DIR}/y.tab.h ${BUILD_DIR}/y.tab.c
	gcc -o ${BUILD_DIR}/prog ${BUILD_DIR}/*.c -I${BUILD_DIR} -I${INCLUDE_DIR} -w

run: input
	./${BUILD_DIR}/prog input ${m}

crun: build run

tests:
	./${BUILD_DIR}/prog ${TEST_DIR}/test_${n} ${m} > out

ctests: build tests
