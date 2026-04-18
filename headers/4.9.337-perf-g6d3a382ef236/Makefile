# Perseus kernel headers Makefile — portable, self-referencing

VERSION = 4
PATCHLEVEL = 9

lastword = $(word $(words $(1)),$(1))
makedir := $(dir $(call lastword,$(MAKEFILE_LIST)))
HEADERS_DIR := $(patsubst %/,%,$(abspath $(makedir)))

ifeq ("$(origin V)", "command line")
VERBOSE := $(V)
endif
ifneq ($(VERBOSE),1)
Q := @
endif

MAKEARGS := -C $(HEADERS_DIR)
MAKEARGS += O=$(HEADERS_DIR)

MAKEFLAGS += --no-print-directory

.PHONY: __sub-make $(MAKECMDGOALS)

__sub-make:
	$(Q)$(MAKE) $(MAKEARGS) $(MAKECMDGOALS)

$(filter-out __sub-make, $(MAKECMDGOALS)): __sub-make
	@:
