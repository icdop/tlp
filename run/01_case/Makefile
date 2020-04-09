#
#
#
TECH_NODE    = T28HPC/0p5

TECHLIB_HOME  := techLib
TECHLIB_RELN  := releaseNotes
TECHLIB_CFGS  := configs
TECHLIB_PKGS  := packages

TLP_BIN     := $(TLP_HOME)/bin
TLP_IMPORT  := $(TLP_BIN)/tlp_import
TLP_INSTALL := $(TLP_BIN)/tlp_install
TLP_CHECK   := $(TLP_BIN)/tlp_check

BUNDLE_FILE  = bundleFile.txt
BUNDLE_LIB   = bundleLib

TLP_OPTIONS  = --info --selectCategory $(TECH_NODE)
TLP_OPTIONS += --packageCfgDir $(TECHLIB_CFGS) --releaseNoteDir $(TECHLIB_RELN) 
TLP_OPTIONS += --packageSrcDir $(TECHLIB_PKGS) --targetLibDir $(TECHLIB_HOME)


help:
	@echo "Usage:"
	@echo "  make clean         ; clean up previouse run log and data"
	@echo "  make env           ; show all environment variables"
	@echo "  make import        ; import *.tlp to releaseNotes"
	@echo "  make install       ; install collateral pacakge to $(TECHLIB_HOME)"
	@echo ""
	@echo "  make bundle        ; create bundleLib at $(BUNDLE_LIB)"
	@echo "  make diff          ; compare $(TECHLIB_HOME)/ with $(BUNDLE_LIB)/"
	@echo ""

run: import install_test bundle diff

env:
	@echo "=========================================="
	@echo "TECHLIB_HOME = $(TECHLIB_HOME)"
	@echo "TECHLIB_CFGS = $(TECHLIB_CFGS)"
	@echo "TECHLIB_PKGS = $(TECHLIB_PKGS)"
	@echo "TECHLIB_RELN = $(TECHLIB_RELN)"
	@echo "=========================================="
	
pdk:
	$(TLP_IMPORT) $(TLP_OPTIONS) $(TECHLIB_PKGS)/PT28HPCPDK_r0.6.1.tlp

error:
	$(TLP_IMPORT) $(TLP_OPTIONS) --packageCfgDir errors
		
import: $(TECHLIB_CFGS)
	$(TLP_IMPORT) $(TLP_OPTIONS)

install: $(TECHLIB_RELN)
	$(TLP_INSTALL) $(TLP_OPTIONS)

install_test:  $(TECHLIB_RELN)
	$(TLP_INSTALL) --log install_test.log $(TLP_OPTIONS) < script/install_test.cmd


bundle: $(BUNDLE_FILE)
	$(TLP_INSTALL) --log tlp_bundle.log $(TLP_OPTIONS)  --targetLibDir $(BUNDLE_LIB) --bundleList $(BUNDLE_FILE)

$(BUNDLE_FILE): $(TECHLIB_HOME)/$(TECH_NODE)/.tlp_packages
	@echo
	cp -f $(TECHLIB_HOME)/$(TECH_NODE)/.tlp_packages $(BUNDLE_FILE)
	@echo
	@echo "=========================================="
	@cat $(BUNDLE_FILE)
	@echo "=========================================="
	@echo

summary: $(TECHLIB_HOME)/.tlp_install.summary
	cat $(TECHLIB_HOME)/.tlp_install.summary


diff:
	diff -r $(BUNDLE_LIB) $(TECHLIB_HOME)

clean:
	rm -fr $(TECHLIB_RELN)
	rm -fr $(TECHLIB_HOME)
	rm -fr $(BUNDLE_LIB)
	rm -fr *.txt *.log *.log.*

