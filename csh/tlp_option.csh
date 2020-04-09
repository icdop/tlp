#!/bin/csh -f
#set verbose=1
set prog = $0:t
if (($1 == "-h")||($1 == "--help")) then
   echo "Usage: $prog <options>"
   echo "  --targetLibDir    <techLibDir>  	(TECHLIB_HOME)"
   echo "  --packageCfgDir   <packageConfigDir>	(TECHLIB_CFGS)"
   echo "  --packageSrcDir   <packageSourceDir>	(TECHLIB_PKGS)"
   echo "  --releaseNoteDir  <releaseNoteDir>	(TECHLIB_RELN)"
   echo "  --bundleFile      <BundleListFile>"
   echo "  --selectCategory  <NODE/PDK/GROUP/TYPE>"
   echo "Description:"
   echo "  "
   exit -1
endif

set parse_option=1
while ($parse_option) 
  switch($1)
      case "-v":
      case "--verbose":
        set verbose_mode=1
        shift argv
      breaksw

      case "-i":
      case "--info":
        set info_mode=1
        shift argv
      breaksw

      case "-c":
      case "--packageCfgDir":
        shift argv
        setenv TECHLIB_CFGS $1
        echo "INFO:   --packageCfgDir	$TECHLIB_CFGS"
        shift argv
      breaksw 

      case "-p":
      case "--packageSrcDir":
        shift argv
        setenv TECHLIB_PKGS $1
        echo "INFO:   --packageSrcDir	$TECHLIB_PKGS"
        shift argv
      breaksw 

      case "-r":
      case "--releaseNoteDir":
        shift argv
        setenv TECHLIB_RELN $1
        echo "INFO:   --releaseNoteDir	$TECHLIB_RELN"
        shift argv
      breaksw 

      case "-t":
      case "--targetLibDir":
        shift argv
        setenv TECHLIB_HOME $1
        echo "INFO:   --targetLibDir	$TECHLIB_HOME"
        shift argv
      breaksw 

      case "--packCfgDir":
      case "--packCfgsDir":
        shift argv
        setenv TLP_CFGS_DEST $1
        echo "INFO:   --packCfgDir	$TLP_CFGS_DEST"
        shift argv
      breaksw 

      case "--packDestDir":
        shift argv
        setenv TLP_PKGS_DEST $1
        echo "INFO:   --packDestDir	$TLP_PKGS_DEST"
        shift argv
      breaksw 

      case "--packTempDir":
        shift argv
        setenv TLP_PACK_TEMP $1
        echo "INFO:   --packTempDir	$TLP_PACK_TEMP"
        shift argv
      breaksw 

      case "-c":
      case "--selectByCategory":
      case "--selectCategory":
        shift argv
        set kit_category=$1
        echo "INFO:   --selectCategory	$kit_category"
        shift argv
      breaksw 

      case "-b":
      case "--bundleFile":
      case "--bundleList":
        shift argv
        set bundleFile=$1
        echo "INFO:   --bundleFile	$bundleFile"
        shift argv
      breaksw 

      default:
        set parse_option=0
      breaksw
  endsw
end 

if ($?TECHLIB_HOME == 0) then
   setenv TECHLIB_HOME "techLib"
endif

if ($?TECHLIB_RELN == 0) then
   setenv TECHLIB_RELN "releaseNotes"
endif

if ($?TECHLIB_PKGS == 0) then
   setenv TECHLIB_PKGS "packages"
endif

if ($?TECHLIB_CFGS == 0) then
   setenv TECHLIB_CFGS $TECHLIB_PKGS
endif

if ($?TLP_PKGS_DEST == 0) then
   setenv TLP_PKGS_DEST "packages"
endif

if ($?TLP_CFGS_DEST == 0) then
   setenv TLP_CFGS_DEST $TLP_PKGS_DEST
endif

if ($?kit_category == 0) then
   set kit_category=""
endif

if ($?bundleFile == 0) then
   set bundleFile=""
endif

if ($?info_mode) then
   echo "TECHLIB_HOME = $TECHLIB_HOME"
   echo "TECHLIB_RELN = $TECHLIB_RELN"
   echo "TECHLIB_PKGS = $TECHLIB_PKGS"
   echo "TECHLIB_CFGS = $TECHLIB_PKGS"
endif

echo "--------------------------------------------------------"
exit 0
