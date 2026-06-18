CC := gcc
CFLAGS := -Wall -Wextra

SRC_DIR := src
BIN_DIR := bin

SOURCES := $(wildcard $(SRC_DIR)/*.c)
PROGRAMS := $(notdir $(basename $(SOURCES)))
TARGETS := $(addprefix $(BIN_DIR)/,$(PROGRAMS))

release: $(TARGETS)

$(BIN_DIR)/%: $(SRC_DIR)/%.c | $(BIN_DIR)
	$(CC) $(CFLAGS) $< -o $@

%:
	@if [ -f "$(SRC_DIR)/$@.c" ]; then \
		echo "--- Compiling $(SRC_DIR)/$@.c -> $(BIN_DIR)/debug ---"; \
		$(CC) $(CFLAGS) $(SRC_DIR)/$@.c -o $(BIN_DIR)/debug; \
		echo "--- Running $(BIN_DIR)/debug ---"; \
		$(BIN_DIR)/debug $(ARGS); \
	else \
		echo "Unknown target: $@"; \
		exit 1; \
	fi

$(BIN_DIR):
	mkdir -p $@

.PHONY: clean release

clean:
	rm -rf $(BIN_DIR)