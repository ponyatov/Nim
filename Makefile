## `GNU make` build scripts
#
# gnu make is the most portable build tool, and available on any $HOST operating system:
#   Linux: sudo apt install make
# Windows: MinGW, nmake
#
# IEEE Std 1003.1-2017: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html

## common variables

# full path of the current directory
CWD     = $(CURDIR)

# module name /lowercased/
MODULE  = $(shell echo $(notdir $(CWD)) | tr "[:upper:]" "[:lower:]" )

# host OS on which we run GNU make (predefined in Windows as `Windows_NT`)
OS     ?= $(shell uname -s)
# [t]arget OS (same as host by default)
TOS    ?= $(OS)

## architecture triplets (canadian cross convention)

# system we use for cross-compilers build
BUILD     = $(shell gcc -dumpmachine)
# system we work on
HOST     ?= $(BUILD)
# target architecture (microcontroller, desktop computer,..)
# equal to $HOST by default, but must be reassigned to something like
# TARGET  = arm-none-eabi
# TARGET  = i486-elf
# TARGET  = i686-w64-mingw32
TARGET   ?= $(HOST)

## POSIX tools assigned to standard variables

# host
CC       = $(HOST)-gcc
LD       = $(HOST)-ld
SIZE     = $(HOST)-size
OBJDUMP  = $(HOST)-objdump

# target: cross-compiler variables prefixed with `T`
TCC      = $(TARGET)-gcc
TLD      = $(TARGET)-ld
TSIZE    = $(TARGET)-size
TOBJDUMP = $(TARGET)-objdump

## choosenim installed Nim tools
# NIMBLE  = $(HOME)/.nimble/bin/nimble
# NIM     = $(HOME)/.nimble/bin/nim
NPRETTY = $(HOME)/.nimble/bin/nimpretty

## detect number of CPU cores
CORES   = $(shell grep processor /proc/cpuinfo|wc -l)


.PHONY: all
all: build

.PHONY: build
build: bin/nim

bin/nim: csources/makefile
	cd csources ; CC=$(CC) CFLAGS="-march=native" $(MAKE) -j$(CORES)

csources/makefile:
	git clone -v --depth 1 https://github.com/nim-lang/csources.git



## install/update scripts

.PHONY: install update

install: $(OS)_install $(TARGET)_$(OS)_install
update: $(OS)_update $(TARGET)_$(OS)_update

.PHONY: Linux_install Linux_update

Linux_install Linux_update:
	sudo apt update
	sudo apt install -u `cat apt.txt`

.PHONY: x86_64-linux-gnu_Linux_install x86_64-linux-gnu_Linux_update

x86_64-linux-gnu_Linux_install x86_64-linux-gnu_Linux_update:

.PHONY: install-mingw

install-mingw:
	TARGET=i686-w64-mingw32 $(MAKE) install

.PHONY: i686-w64-mingw32_Linux_install i686-w64-mingw32_Linux_update

i686-w64-mingw32_Linux_install:
	sudo dpkg --add-architecture i386
	make i686-w64-mingw32_Linux_update
i686-w64-mingw32_Linux_update:
	sudo apt install -u `cat apt.mingw`

# $(NIMBLE):
# 	curl https://nim-lang.org/choosenim/init.sh -sSf | sh



.PHONY: master shadow release

MERGE  = Makefile readme.md cross.md .gitignore
MERGE += apt.txt apt.mingw

master:
	git checkout $(USER)-cross
	git pull -v
	git checkout $(USER)-shadow -- $(MERGE)

shadow:
	git checkout $(USER)-shadow
	git pull -v

release:
	git tag $(NOW)-$(REL)
	git push -v && git push -v --tags
	$(MAKE) shadow
