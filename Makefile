# picolisp-json Makefile

PIL_MODULE_DIR ?= .modules
REPO_PREFIX ?= https://github.com/aw

# Unit testing
TEST_REPO = $(REPO_PREFIX)/picolisp-unit.git
TEST_DIR = $(PIL_MODULE_DIR)/picolisp-unit/HEAD
TEST_REF = v3.0.0

.PHONY: all

all: check

$(TEST_DIR):
		mkdir -p $(TEST_DIR) && \
		git clone $(TEST_REPO) $(TEST_DIR) && \
		cd $(TEST_DIR) && \
		git checkout $(TEST_REF)

check: $(TEST_DIR) run-tests

run-tests:
		./test.l
