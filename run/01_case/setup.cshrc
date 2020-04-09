#!/bin/csh -f
if ($?TLP_HOME == 0) then
   echo "ERROR: setenv TLP_HOME first before runing demo" 
endif

setenv TECHLIB_HOME techLib
setenv TECHLIB_PKGS packages
setenv TECHLIB_RELN releaseNotes

echo "=========================================="
echo "TECHLIB_HOME = $TECHLIB_HOME"
echo "TECHLIB_PKGS = $TECHLIB_PKGS"
echo "TECHLIB_RELN = $TECHLIB_RELN"
echo "=========================================="

make help

