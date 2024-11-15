# OS detection
UNAME_S := $(shell uname -s)

# Linux build flags
ifeq ($(UNAME_S),Linux)
	CC = g++
	CXXFLAGS = -O0 -g -Ibuild -Itest/framework -Wall
	LDFLAGS =
	CLEANFLAGS = find test -type f -executable -delete
	RUNFLAGS = find test -type f -executable -print0 | xargs -0 -I % bash -c %
endif
# macOS build flags
ifeq ($(UNAME_S),Darwin)
	CC = clang++
	CXXFLAGS = -O0 -g -Ibuild -Itest/framework -Wall --std=c++14
	LDFLAGS =
	CLEANFLAGS = find test -type f -perm +111 -delete
	RUNFLAGS = find test -type f -perm +111 -print0 | xargs -0 -I % bash -c %
endif


RUNNER_SRCS := runner/main.cpp runner/directory.cpp runner/process.cpp runner/output.cpp runner/runner.cpp
TEST_SRCS := $(shell find test -name '*.cpp')
TESTS := $(basename $(TEST_SRCS))

test: all

all: build $(TESTS) run

runner: build
	g++ $(RUNNER_SRCS) -std=c++17 -g -O0 -o build/cest-runner
	g++ runner/test/runner.test.cpp runner/runner.cpp runner/test/helpers/helpers.cpp -Ibuild -std=c++17 -g -O0 -o runner/test/test_runner

runner-tests: runner
	cd runner && ../build/cest-runner

build:
	mkdir -p build
	quom src/main.hpp build/cest
	python scripts/remove_duplicated_headers.py build/cest
	python scripts/remove_duplicated_once_blocks.py build/cest

run:
	@$(RUNFLAGS)

clean:
	@$(CLEANFLAGS)
	@rm -f log.xml
	@rm -f *.jsonl
	@rm -rf build
	@rm -rf runner/test/test_runner

.PHONY: clean run build test runner runner-tests
