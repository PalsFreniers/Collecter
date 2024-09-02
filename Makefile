C3 = c3c
SRCS =  src/main.c3
SRCS += src/tests/tests_launch.c3 \
	src/tests/tests_get_next_collection.c3
NAME = collecter

all: $(NAME) test bench

$(NAME): $(SRCS)
	$(C3) compile $(SRCS) -o $(NAME)

test: $(SRCS)
	$(C3) compile-test $(SRCS) -o $(NAME)

bench: $(SRCS)
	$(C3) compile-benchmark $(SRCS) -o $(NAME)

clean:
	rm -rf **/*.o $(NAME) benchmarkrun testrun

.PHONY: all test bench clean
