#
# Makefile
# =============================================================================
# Customers API Lite microservice prototype (V port). Version 0.0.7
# =============================================================================
# A daemon written in V (vlang/veb), designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

BIN_DIR = bin

PREF = api-lite
EXEC = $(BIN_DIR)/$(PREF)d
DEPS = .

# Specify flags and other vars here.
V      = v
VFLAGS = -o $(EXEC)

MKDIR   = mkdir
RMFLAGS = -vR

# Making the target (the microservice executable).
$(EXEC): $(DEPS)
	if [ ! -d $(BIN_DIR) ]; then \
	    $(MKDIR) $(BIN_DIR); \
	fi
	$(V) $(VFLAGS) $(DEPS)

.PHONY: all clean

all: $(EXEC)

clean:
	$(RM) $(RMFLAGS) $(BIN_DIR)

# vim:set nu et ts=4 sw=4:
