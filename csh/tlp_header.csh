#!/bin/csh -f
#set verbose=1
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

      case "-l":
      case "--log":
        shift argv
        set log_file=$1
        shift argv
        
      default:
        set parse_option=0
      breaksw
  endsw
end 
if ($?log_file == 0) then
   set log_file = "tlp_header.log"
endif
if {(test -f $log_file)} then
   set n=1
   while {(test -f $log_file.$n)}
      set n=`expr $n + 1`
   end
   mv $log_file $log_file.$n
endif
printf "\033[1m\033[34m"
echo -n "" | tee $log_file
echo "######################################################################" | tee -a $log_file
echo "# TechLib Package (TLP) Management Utility v2020.0410" | tee -a $log_file
echo "######################################################################" | tee -a $log_file
printf "\033[0m"
exit 0
