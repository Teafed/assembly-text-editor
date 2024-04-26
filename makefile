# directories
OBJ_DIR = ./obj
EXTERNAL_FUNCTIONS_DIR = ./external-functions

# source list
SRCS = $(wildcard *.s)

# object list
EXTERNAL_OBJS = $(wildcard $(EXTERNAL_FUNCTIONS_DIR)/*.o)

# generate .o files
OBJS = $(patsubst %.s,$(OBJ_DIR)/%.o,$(SRCS))

# assemble .o files
$(OBJ_DIR)/%.o: %.s
	as -g $< -o $@

# link objects with driver
driver: $(OBJS) $(EXTERNAL_OBJS)
	ld -o driver $(OBJS) $(EXTERNAL_OBJS) -lc

# clean up
clean:
	rm -f $(OBJ_DIR)/*.o driver

.PHONY: clean
