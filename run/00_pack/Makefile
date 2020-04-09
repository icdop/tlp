#
#
#
TECH_NODE   := T28HPC/0p5 

TECHLIB_HOME  := techLib
TECHLIB_CFGS  := configs
TECHLIB_PKGS  := packages
TECHLIB_RELN  := releaseNotes
BUNDLE_LIB  := bundleLib

TLP_BIN     := $(TLP_HOME)/bin
TLP_PACK    := $(TLP_BIN)/tlp_pack
TLP_IMPORT  := $(TLP_BIN)/tlp_import
TLP_INSTALL := $(TLP_BIN)/tlp_install
TLP_CHECK   := $(TLP_BIN)/tlp_check

TLP_PACK_TEMP  = tempLib

COLLATERAL_CSV = collateral_r061.csv collateral_r101.csv
PATCH_CSV      = patch_pdk222_r101.csv
BUNDLE_LIST    = collateral_r061.bundle collateral_r101.bundle


TLP_OPTIONS  = --info --selectCategory $(TECH_NODE)
TLP_OPTIONS += --packageCfgDir $(TECHLIB_CFGS) --releaseNoteDir $(TECHLIB_RELN) 
TLP_OPTIONS += --packageSrcDir $(TECHLIB_PKGS) --targetLibDir $(TECHLIB_HOME)

TLP_PACK_OPT = --packCfgsDir $(TECHLIB_CFGS) --packDestDir $(TECHLIB_PKGS) --packTempDir $(TLP_PACK_TEMP) 


help:
	@echo "Usage:"
	@echo "  make clean         ; clean up previouse data"
	@echo "  make pack          ; pack collateral tlp and tar ball"
	@echo "  make bundle        ; create bundle lib"
	@echo ""

run:	pack bundle 

pack:
	$(TLP_PACK) $(TLP_PACK_OPT) $(COLLATERAL_CSV)

patch:
	$(TLP_PACK) $(TLP_PACK_OPT) $(PATCH_CSV)

import:
	$(TLP_IMPORT) $(TLP_OPTIONS)

install: $(TECHLIB_RELN)
	$(TLP_INSTALL) $(TLP_OPTIONS)

bundle: $(BUNDLE_LIST)
	@for file in $(BUNDLE_LIST); do \
	$(TLP_INSTALL) $(TLP_OPTIONS)  --targetLibDir $(BUNDLE_LIB) --bundleList $$file; \
	done;

diff:
	diff -r $(BUNDLE_LIB) $(TECHLIB_HOME)

$(TECHLIB_RELN): import

$(TECHLIB_HOME): install

$(BUNDLE_LIST): pack

clean:
	rm -fr $(TECHLIB_HOME)
	rm -fr $(TECHLIB_CFGS)
	rm -fr $(TECHLIB_PKGS)
	rm -fr $(TECHLIB_RELN)
	rm -fr $(TECHLIB_TEMP)
	rm -fr $(TLP_PACK_TEMP)
	rm -fr $(BUNDLE_LIB)
	rm -fr *.log *.bundle *.log.*

