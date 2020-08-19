#!/bin/csh -f
#set verbose=1
set prog = $0:t
if (($1 == "-h")||($1 == "--help")) then
   echo "Usage: $prog <options> <pacakge.tlp>"
   echo "  --packageSrcDir   <packageSourceDir>	(TECHLIB_PKGS)"
   echo "  --dataSheetDir  <dataSheetDir>	(TECHLIB_DOCS)"
   echo "  --targetLibDir    <techLibDir>  	(TECHLIB_ROOT)"
   echo "  --bundleFile      <BundleListFile>"
   echo "  --selectByCategory  <NODE/MVER/CATG/TYPE>"
   echo "Description:"
   echo "  Install designkit package based on tlp config file."
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

set menu_mode=1
set menu_category = 1
set menu_list_all = 1

set name_list=
if ($bundleFile != "") then
   if {(test -e $bundleFile)} then
      set name_list = `cat $bundleFile`
   else 
      printf "\033[31mERROR: file not found - '$bundleFile‘.\033[0m\n"
      exit 1
   endif
endif

while($1 != "")
   set name_list = ($name_list $1)
   shift argv
end

if ("$name_list" != "") then
   set n=0
   set tlp_list=
   foreach tlp_name ($name_list)
     set n=`expr $n + 1`
     echo -n "[$n]: Checking tlp package - $tlp_name ..."
     if {(test -f $tlp_name)} then
       set tlp_file = $tlp_name
     else if {(test -f $TECHLIB_CFGS/$tlp_name)} then
       set tlp_file = $TECHLIB_CFGS/$tlp_name
     else if {(test -f $TECHLIB_CFGS/$tlp_name.tlp)} then
       set tlp_file = $TECHLIB_CFGS/$tlp_name.tlp
     else
       printf "\n\033[31mERROR: Can not find TLP config '$tlp_name' in '$TECHLIB_CFGS'.\033[0m\n"
       exit 1
     endif
     set tlp_list = ($tlp_list $tlp_file )
     echo ""
   end
   /usr/bin/gawk -f $TLP_HOME/csh/tlp_install.awk $tlp_list | tee -a $log_file
   set menu_mode = 0
else
   if ($?TECHLIB_DOCS == 0) then
      printf "\033[31mERROR: dataSheet path env(TECHLIB_DOCS) is not specified.\033[0m\n"
      exit 1
   else if {(test -d $TECHLIB_DOCS)} then
   #   echo "INFO: TECHLIB_DOCS = $TECHLIB_DOCS"
   else
      printf "\033[31mERROR: dataSheet directory '$TECHLIB_DOCS' does not exist.\033[0m\n"
      exit 1
   endif
endif

while ($menu_mode == 1)
   while ($menu_category == 1) 
     clear
     echo "INFO: TECHLIB_DOCS = $TECHLIB_DOCS"
     echo "=============================================================="
     echo "INFO: Please specify Kit Category :"
     (cd $TECHLIB_DOCS; tree --noreport -C -d -L 4 .)
     echo -n "INPUT: Category = ($kit_category) ? " 
     set kit_category = "$<"
     echo $kit_category
     if {(test -d $TECHLIB_DOCS/$kit_category )} then
       set menu_category = 0
     else
       set kit_category = ""
     endif
   end

   
   set sel_list=
   set menu_package=1
   while ($menu_package == 1)
     echo "=============================================================="
     echo "INFO: Please select the following packages to be installed :"
     echo "[ $TECHLIB_DOCS/$kit_category ]:"
     set tlp_list = `cd $TECHLIB_DOCS; find $kit_category -name \*.dts -print | sort`
     set n=0
     
     printf "\033[1m"
     echo "  $n) Go back to previous selection menu.."
     printf "\033[0m\033[34m"
     printf "   %4s %-40s :%-7s :%-20s\n" "----" "-----------------------------------" "-------" "--------------------"
     printf "   %4s %-40s :%-7s :%-20s\n" "#" "SKU" "TYPE" "TOPDIR"
     printf "   %4s %-40s :%-7s :%-20s\n" "----" "-----------------------------------" "-------" "--------------------"
     foreach tlp_file ($tlp_list)
        set kit_basename=$tlp_file:t:r
        set kit_topdir=$tlp_file:h:t
        set kit_type=$tlp_file:h:h:t
        if {(test -f $TECHLIB_ROOT/.tlp_install/$kit_basename.tlp)} then
           if ($menu_list_all) then
              set n=`expr $n + 1`
              printf "\033[0m\033[34m"
              printf "  *%3d) %-40s :%-7s :%-20s\n" $n $kit_basename $kit_type $kit_topdir
           endif
        else
           set n=`expr $n + 1`
           printf "\033[1m\033[34m"
           printf "   %3d) %-40s :%-7s :%s\n" $n $kit_basename $kit_type $kit_topdir
        endif
     end
     printf "\033[0m"
     if ($menu_list_all) then
     echo "  h) hide installed packages.."
     else
     echo "  a) list all packages.."
     endif
     echo "  t) print directory tree.."
     printf "\033[1m"
     echo "  q) quit.."
     printf "\033[0m"
     
     echo -n "INPUT: Select ? "
     set sel_list = "$<"
     set menu_package = 0
   end
   echo $sel_list
   echo "========================================================"

   foreach sel ($sel_list)
      if ($sel == "q") then
         set menu_mode = 0
         exit 0
      else if (($sel == "a")||($sel == "A")) then
         set menu_list_all = 1
      else if (($sel == "t")||($sel == "T")) then
         echo "=============================================================="
         echo "INFO: Current data Sheet directory: "
         tree -n  $TECHLIB_DOCS/$kit_category | less
      else if (($sel == "h")||($sel == "H")) then
         set menu_list_all = 0
      else if ($sel == 0) then
         set menu_category = 1
         echo "INFO: Reselect Catgory.."
      else if (`expr match $sel '[0-9]*'` == 0) then
         printf "\033[31mERROR: Invalid selection : $sel \033[0m\n" 
      else if ($sel > $n) then
         printf "\033[31mERROR: selection over the range : (1~$n) \033[0m\n" 
      else
         set tlp_file = $TECHLIB_DOCS/$tlp_list[$sel]
         if {(test -f $tlp_file)} then
            echo "INFO: Install kit '$tlp_list[$sel]' .."
            /usr/bin/awk -f $TLP_HOME/csh/tlp_install.awk $tlp_file | tee -a $log_file
         else
            printf "\033[31mERROR: file not found - $tlp_file \033[0m\n"
         endif
      endif       
   end
#   mkdir -p $TECHLIB_ROOT
#   tree --noreport -L 5 $TECHLIB_ROOT
end

echo "TIME: @`date +%Y%m%d_%H%M%S` END   $prog" | tee -a $log_file
echo "========================================================" | tee -a $log_file
exit 0
