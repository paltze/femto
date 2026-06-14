CC := gcc
CFLAGS := -Wall -Wextra
SRC_DIR := src
BIN_DIR := bin

# Rule to compile and run
%: $(SRC_DIR)/%.c | $(BIN_DIR)
	@echo "--- Compiling $< ---"
	$(CC) $(CFLAGS) $< -o $(BIN_DIR)/$*
	@echo "--- Running $(BIN_DIR)/$* ---"
	@$(BIN_DIR)/$* $(ARGS)

$(BIN_DIR):
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf $(BIN_DIR)