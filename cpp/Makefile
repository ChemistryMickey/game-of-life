#Start of the makefile
NAME := main
CC := gcc
CXX := g++
INCLUDE_MODULES := 
INCLUDE_DIRS := $(addprefix /usr/include/,$(INCLUDE_MODULES)) external include
LIBRARIES := $(INCLUDE_MODULES)
VPATH = ./src:./include:./obj

CXXFLAGS += -O2 -g -std=c++20 $(foreach include_dir,$(INCLUDE_DIRS),-I$(include_dir))
CFLAGS += -O2 -g $(foreach include_dir,$(INCLUDE_DIRS),-I$(include_dir))

LDLIBS += $(foreach library,$(LIBRARIES),-l$(library))
Target = $(notdir $(CURDIR))
Objects := $(notdir $(patsubst %.cpp,%.o,$(wildcard src/*.cpp)))
C_Objects := $(notdir $(patsubst %.c,%.o,$(wildcard src/*.c)))
OUTPUT_OPTION = -o obj/$@ # not sure why this is necessary but it is?

all: $(NAME)

$(NAME): $(Objects) $(C_Objects)
	$(LINK.cc) $(CXXFLAGS) -o $(NAME) $(addprefix obj/,$(Objects)) $(addprefix obj/,$(C_Objects)) $(LDLIBS)

.PHONY: clean
clean:
	rm -f $(addprefix obj/,$(Objects)) $(addprefix obj/,$(C_Objects)) $(NAME)

