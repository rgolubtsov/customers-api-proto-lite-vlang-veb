#
# Makefile
# =============================================================================
# Customers API Lite microservice prototype (V port). Version 0.2.7
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

DB_PATH = data/db
DB_FILE = customers-api-lite.db.xz

# Specify flags and other vars here.
V      = v
VFLAGS = -prod -o $(EXEC)

MKDIR   = mkdir
RMFLAGS = -vR
UNXZ    = unxz

# Making the target (the microservice executable).
$(EXEC): $(DEPS)
	if [ ! -d $(BIN_DIR) ]; then \
	    $(MKDIR) $(BIN_DIR); \
	fi
	$(V) $(VFLAGS) $(DEPS) && \
	if [ -f $(DB_PATH)/$(DB_FILE) ]; then \
	    $(UNXZ) $(DB_PATH)/$(DB_FILE); \
	fi

.PHONY: all clean

all: $(EXEC)

clean:
	$(RM) $(RMFLAGS) $(BIN_DIR)

# vim:set nu et ts=4 sw=4:
