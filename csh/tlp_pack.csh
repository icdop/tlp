#!/bin/csh -f
#set verbose=1
set prog = $0:t
if (($1 == "-h")||($1 == "--help")) then
   echo "Usage: $prog <options>"
   echo "  --packageSrcDir   <packageSourceDir>  (TECHLIB_PKGS)"
   echo "  --packageTgtDir   <packageSourceDir>  (TECHLIB_TARGET)"
   echo "  --targetLibDir    <techLibTargetDir>  (TECHLIB_HOME)"
   echo "  --selectByCategory  <NODE/PDK/GROUP/TYPE>"
   echo "Description:"
   echo "  copy tlp config file to releaseNotes directory and sort by kit category"
   echo ""
   exit -1
endif

if ($?TLP_HOME == 0) then
   setenv TLP_HOME $0:h/..
endif

set log_file=tlp_pack.log
source $TLP_HOME/csh/tlp_header.csh

echo "TIME: @`date +%Y%m%d_%H%M%S` BEGIN $prog" | tee -a $log_file
echo "CMDS: $prog $*" | tee -a $log_file

source $TLP_HOME/csh/tlp_option.csh 

set file_list=
while ($1 != "" )
  set file_list=($file_list $1)
  shift argv
end

/usr/bin/gawk -f $TLP_HOME/csh/tlp_pack.awk $file_list | tee -a $log_file

echo "TIME: @`date +%Y%m%d_%H%M%S` END   $prog" | tee -a $log_file
echo "========================================================" | tee -a $log_file
exit 0
