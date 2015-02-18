## CS152 Winter 2014: Compiler Design
## Makefile
##
## This file been modified to work with 
## OS X and Linux
#########################################

OS := $(shell uname)

ifeq ($(OS), Darwin)
LIBS = -L/opt/local/lib/ -lfl
endif

ifeq ($(OS), Linux)
LIBS = -lfl
endif

## Compiler
CC = g++

## Compiler flags
FLAGS = 

## Global header files
INCLUDE = y.output y.tab.h

## Object files and executables
MAIN_OUT = my_compiler

## Requirements for each command
MAIN_REQS =

## Targets to compile for each command
MAIN_TARGETS = y.tab.c lex.yy.c

FLEX_FILE = mini_1.lex
BISON_FILE = mini_1.y
OUTPUT_FILE = output.txt
CORRECT_OUTPUT = mytest.mil
INPUT_FILE = mytest.min
INTERPRETER = mil_run
READ_FILE = input.txt

all:
		bison -v -d --file-prefix=y $(BISON_FILE)
		flex $(FLEX_FILE)
		$(CC) -o $(MAIN_OUT) $(MAIN_TARGETS) $(LIBS)

clean:
		rm -rf *~ $(INCLUDE) $(MAIN_TARGETS) $(MAIN_OUT)

check: out
		diff -aybBs $(OUTPUT_FILE) $(CORRECT_OUTPUT)

out: all
		cat $(INPUT_FILE) | ./$(MAIN_OUT) 1 > $(OUTPUT_FILE)

in: all
		cat $(INPUT_FILE) | ./$(MAIN_OUT) 1
		
run: out
		./$(INTERPRETER) $(OUTPUT_FILE) < $(READ_FILE)
