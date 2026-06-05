CC := gcc
CFLAGS := -Wall -Wextra -g

SRC := src/main.c
OUT := bin/debug

all: run

$(OUT): $(SRC)
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@

run: $(OUT)
	./$(OUT)

clean:
	rm -rf bin