C3 = c3c
SRCS =  src/main.c3 \
        src/collections.c3 \
        src/utils.c3
SRCS += src/string/string.c3
NAME = collecter

all: $(NAME)

$(NAME): $(SRCS)
	$(C3) compile $(SRCS) -o $(NAME) -g

test: $(SRCS)
	$(C3) compile-test $(SRCS) -o $(NAME)

bench: $(SRCS)
	$(C3) compile-benchmark $(SRCS) -o $(NAME)

clean:
	rm -rf **/*.o $(NAME) benchmarkrun testrun

.PHONY: all test bench clean
