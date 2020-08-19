#!/bin/csh -f set verbose=1
set prog = $0:t
if (($1 == "-h")||($1 == "--help")) then
   echo "Usage: $prog <options> <pacakge.tlp>"
   echo "  --packageSrcDir   <packageSourceDir>	(TECHLIB_PKGS)"
   echo "  --dataSheetDir    <dataSheetDir>	(TECHLIB_DOCS)"
   echo "  --targetLibDir    <techLibDir>  	(TECHLIB_ROOT)"
   echo "  --bundleFile      <BundleListFile>"
   echo "  --selectByCategory  <NODE/MVER/CATG/TYPE>"
   echo "Description:"
   echo "  Install designkit package base on package.tlp file."
   echo ""
   exit -1
endif

if ($?TLP_HOME == 0) then
   setenv TLP_HOME $0:h/..
endif

set log_file=tlp_install.log
source $TLP_HOME/csh/tlp_header.csh

echo "TIME: @`date +%Y%m%d_%H%M%S` BEGIN $prog" | tee -a $log_file
echo "CMDS: $prog $*" | tee -a $log_file

source $TLP_HOME/csh/tlp_option.csh

echo "TIME: @`date +%Y%m%d_%H%M%S` END   $prog" | tee -a $log_file
echo "========================================================" | tee -a $log_file
exit 0
