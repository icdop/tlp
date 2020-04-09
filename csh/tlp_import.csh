#!/bin/csh -f
#set verbose=1
set prog = $0:t
if (($1 == "-h")||($1 == "--help")) then
   echo "Usage: $prog <options>"
   echo "  --packageCfgDir   <packageConfigDir>  (TECHLIB_CFGS)"
   echo "  --packageSrcDir   <packageSourceDir>  (TECHLIB_PKGS)"
   echo "  --releaseNoteDir  <releaseNoteDir>    (TECHLIB_RELN)"
   echo "  --selectByCategory  <NODE/PDK/GROUP/TYPE>"
   echo "Description:"
   echo "  copy tlp config file to releaseNotes directory and sort by kit category"
   echo ""
   exit -1
endif

if ($?TLP_HOME == 0) then
   setenv TLP_HOME $0:h/..
endif

set log_file=tlp_import.log
source $TLP_HOME/csh/tlp_header.csh

echo "TIME: @`date +%Y%m%d_%H%M%S` BEGIN $prog" | tee -a $log_file
echo "CMDS: $prog $*" | tee -a $log_file

source $TLP_HOME/csh/tlp_option.csh 

set tlp_list=
while ($1 != "" )
  if {(test -d $1)} then
     set fl=`ls -1 $1/*.tlp`
     foreach f ($fl) 
       set tlp_list=($tlp_list $f)
     end
  else if {(test -f $1)} then
     set tlp_list=($tlp_list $1)
  else
     set SKU=`basename $1 .tlp`
     set tlp_list=($tlp_list `glob $TECHLIB_CFGS/$SKU.tlp`)
  endif
  shift argv
end

if ("$tlp_list" == "") then
echo "INFO: Search tlp file in '$TECHLIB_CFGS'..."
#set tlp_list = `find $TECHLIB_CFGS -name *.tlp -print`
#set tlp_list = (glob  $TECHLIB_CFGS/*.tlp)
set tlp_list = `ls -1 $TECHLIB_CFGS/*.tlp`
#set tlp_list = `echo $TECHLIB_CFGS/*.tlp`
endif

if ( "$tlp_list" != "") then
 /usr/bin/gawk -f $TLP_HOME/csh/tlp_import.awk $tlp_list | tee -a $log_file
endif


echo "TIME: @`date +%Y%m%d_%H%M%S` END   $prog" | tee -a $log_file
echo "========================================================" | tee -a $log_file
exit 0
