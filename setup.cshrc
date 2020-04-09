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
setenv TECHLIB_RELN releaseNotes
setenv TECHLIB_HOME targetLib

echo "=========================================="
echo "TECHLIB_PKGS = $TECHLIB_PKGS"
echo "TECHLIB_RELN = $TECHLIB_RELN"
echo "TECHLIB_HOME = $TECHLIB_HOME"
echo "=========================================="

tlp_help
