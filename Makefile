# Makefile 
CC65_PATH ?=
SOURCE_PATH ?= ./src
DEMOS_PATH ?= ./demos
BUILD_PATH ?= ./build

MYCCFLAGS=-t c16 -O -Cl

ifneq ($(COMSPEC),)
DO_WIN:=1
endif
ifneq ($(ComSpec),)
DO_WIN:=1
endif 

ifeq ($(DO_WIN),1)
EXEEXT = .exe
endif

ifeq ($(DO_WIN),1)
COMPILEDEXT = .exe
else
COMPILEDEXT = .out
endif

MYCC65 ?= cc65$(EXEEXT) $(INCLUDE_OPTS) 
MYCL65 ?= cl65$(EXEEXT) $(INCLUDE_OPTS) 


double_turbo:
	$(CC65_PATH)$(MYCL65) $(MYCCFLAGS) $(MYCFG) \
	--asm-define USE_KERNAL=1 \
	--asm-define STANDARD_IRQ=1 \
	--asm-define DEBUG=1 \
	$(DEMOS_PATH)/double_turbo_test.c \
	$(SOURCE_PATH)/double_turbo.s \
	-o $(BUILD_PATH)/double_turbo.prg
	rm $(SOURCE_PATH)/*.o


####################################################
clean:
	rm -rf *.prg
	rm -rf $(SOURCE_PATH)/*.o
	rm -rf $(DEMOS_PATH)/*.o
	rm -rf ./build/*
	rm -rf main.s

   
all: double_turbo


