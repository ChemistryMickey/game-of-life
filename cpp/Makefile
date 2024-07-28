#Start of the makefile
NAME := main
CC := gcc
CXX := g++
INCLUDE_MODULES := 
INCLUDE_DIRS := $(addprefix /usr/include/,$(INCLUDE_MODULES)) external include
LIBRARIES := $(INCLUDE_MODULES)
VPATH = ./src:./include:./obj

CXXFLAGS = -std=c++20 $(foreach include_dir,$(INCLUDE_DIRS),-I$(include_dir))
CXXFLAGS_DEBUG = -g $(CXXFLAGS)
CXXFLAGS_RELEASE = $(CXXFLAGS) -O2

DEFINES = 
DEFINES_DEBUG = $(DEFINES) DEBUG_PRINT
DEFINES_RELEASE = $(DEFINES)

LDLIBS += $(foreach library,$(LIBRARIES),-l$(library))
Target = $(notdir $(CURDIR))
Objects := $(notdir $(patsubst %.cpp,%.o,$(wildcard src/*.cpp)))
C_Objects := $(notdir $(patsubst %.c,%.o,$(wildcard src/*.c)))
OUTPUT_OPTION = -o obj/$@ # not sure why this is necessary but it is?

all: debug

debug: $(Objects) $(C_Objects)
	$(LINK.cc) $(CXXFLAGS_DEBUG) -o debug $(addprefix obj/,$(Objects)) $(addprefix obj/,$(C_Objects)) $(LDLIBS) $(addprefix -D,$(DEFINES_DEBUG))

release: $(Objects) $(C_Objects)
	$(LINK.cc) $(CXXFLAGS_RELEASE) -o release $(addprefix obj/,$(Objects)) $(addprefix obj/,$(C_Objects)) $(LDLIBS)

.PHONY: clean
clean:
	rm -f $(addprefix obj/,$(Objects)) $(addprefix obj/,$(C_Objects)) debug release

