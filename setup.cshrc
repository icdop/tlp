#!/bin/csh -f
set prog=$0:t
echo $prog
if ("$prog" == "setup.cshrc") then
   setenv TLP_HOME `realpath $0:h`
else
   setenv TLP_HOME `pwd`
endif

echo "=========================================="
echo "TLP_HOME = $TLP_HOME"
set path = ($TLP_HOME/bin $path)

setenv TECHLIB_PKGS $TLP_HOME/packages
setenv TECHLIB_DOCS dataSheets
setenv TECHLIB_ROOT targetLib

echo "=========================================="
echo "TECHLIB_PKGS = $TECHLIB_PKGS"
echo "TECHLIB_DOCS = $TECHLIB_DOCS"
echo "TECHLIB_ROOT = $TECHLIB_ROOT"
echo "=========================================="

tlp_help
