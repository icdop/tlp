#!/bin/csh -f
#set verbose=1
set prog = $0:t
if (($1 == "-h")||($1 == "--help")) then
   echo "Usage: $prog <options>"
   echo "  --targetLibDir    <techLibDir>  	(TECHLIB_ROOT)"
   echo "  --packageCfgDir   <packageConfigDir>	(TECHLIB_CFGS)"
   echo "  --packageSrcDir   <packageSourceDir>	(TECHLIB_PKGS)"
   echo "  --dataSheetDir    <dataSheetDir>	(TECHLIB_DOCS)"
   echo "  --bundleFile      <BundleListFile>"
   echo "  --selectByCategory<NODE/MVER/CATG/TYPE>"
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
      case "--dataSheetDir":
        shift argv
        setenv TECHLIB_DOCS $1
        echo "INFO:   --dataSheetDir	$TECHLIB_DOCS"
        shift argv
      breaksw 

      case "-t":
      case "--targetLibDir":
        shift argv
        setenv TECHLIB_ROOT $1
        echo "INFO:   --targetLibDir	$TECHLIB_ROOT"
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

      case "--tempDir":
        shift argv
        setenv TECHLIB_TEMP $1
        echo "INFO:   --tempDir	$TECHLIB_TEMP"
        shift argv
      breaksw 

      case "-s":
      case "--selectByCategory":
        shift argv
        set kit_category=$1
        echo "INFO:   --selectByCategory	$kit_category"
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

if ($?TECHLIB_ROOT == 0) then
   setenv TECHLIB_ROOT "techLib"
endif

if ($?TECHLIB_DOCS == 0) then
   setenv TECHLIB_DOCS "dataSheets"
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
   echo "TECHLIB_ROOT = $TECHLIB_ROOT"
   echo "TECHLIB_DOCS = $TECHLIB_DOCS"
   echo "TECHLIB_PKGS = $TECHLIB_PKGS"
   echo "TECHLIB_CFGS = $TECHLIB_PKGS"
endif

echo "--------------------------------------------------------"
exit 0
