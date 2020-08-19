#!/bin/csh -f
if ($?TLP_HOME == 0) then
   echo "ERROR: setenv TLP_HOME first before runing demo" 
endif

setenv TECHLIB_PKGS packages
setenv TECHLIB_DOCS dataSheets
setenv TECHLIB_ROOT techLib

echo "=========================================="
echo "TECHLIB_PKGS = $TECHLIB_PKGS"
echo "TECHLIB_DOCS = $TECHLIB_DOCS"
echo "TECHLIB_ROOT = $TECHLIB_ROOT"
echo "=========================================="

make help

