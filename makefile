.PHONY: help install uninstall
.DEFAULT_GOAL := install

CTAGS_DIR := $(HOME)/.ctags.d

help:
	@echo "Project Build Targets:"
	@echo "  install     - Install system-wide"
	@echo "  uninstall   - Remove installed files"
	@echo ""
	@echo "Miscellaneous:"
	@echo "  help        - Show this help"
	@echo ""



## ----------------------------------------------------------------------------
# @section PROJECT_TARGETS


install:
	mkdir -p $(CTAGS_DIR)
	cp ./ctags-rules/dan.ctags $(CTAGS_DIR)/dan.ctags

uninstall:
	-rm $(CTAGS_DIR)/dan.ctags


## EOF EOF EOF PROJECT_TARGETS
## ----------------------------------------------------------------------------
