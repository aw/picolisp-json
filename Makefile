# picolisp-json Makefile

MODULE_DIR ?= .modules
SYMLINK_DIR ?= .lib

## Edit below
BUILD_REPO = https://github.com/kgabis/parson.git
BUILD_DIR = $(MODULE_DIR)/parson/HEAD
TARGET = libparson.so
FILES = parson.c
CFLAGS = -O2 -g -Wall -Wextra -std=c89 -pedantic-errors -fPIC -shared
## Edit above

# Unit testing
TEST_REPO = https://github.com/aw/picolisp-unit.git
TEST_DIR = $(MODULE_DIR)/picolisp-unit/HEAD

# Generic
CC = gcc

COMPILE = $(CC) $(CFLAGS)

SHARED = -Wl,-soname,$(TARGET)

.PHONY: all clean

all: $(BUILD_DIR) $(BUILD_DIR)/$(TARGET) symlink

$(BUILD_DIR):
		mkdir -p $(BUILD_DIR) && \
		git clone $(BUILD_REPO) $(BUILD_DIR)

$(TEST_DIR):
		mkdir -p $(TEST_DIR) && \
		git clone $(TEST_REPO) $(TEST_DIR)

$(BUILD_DIR)/$(TARGET):
		cd $(BUILD_DIR) && \
			$(COMPILE) $(SHARED) -o $(TARGET) $(FILES) && \
			strip --strip-unneeded $(TARGET)

symlink:
		mkdir -p $(SYMLINK_DIR) && \
			cd $(SYMLINK_DIR) && \
			ln -sf ../$(BUILD_DIR)/$(TARGET) $(TARGET)

check: all $(TEST_DIR) run-tests

run-tests:
		./test.l

clean:
		cd $(BUILD_DIR) && \
			rm -f $(TARGET) && \
			cd - && \
			cd $(SYMLINK_DIR) && \
			rm -f $(TARGET)
