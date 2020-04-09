#!/usr/bin/gawk -f
function HEADER(message)  { print "\033[34;40m"message"\033[0m" }
function HILITE(message)  { print "\033[1m"message"\033[0m" }
function WARNING(message) { print "\033[34mWARNING: "message"\033[0m" }
function ERROR(message)   { print "\033[31;43mERROR: "message"\033[0m" }
function PRINT(message)   { print "\033[31m"message"\033[0m" }
function DEBUG(message)   { print "\033[35mDEBUG: "message"\033[0m" }
function find_tlp_package(fname) {
  pkgs_file=""
#  tlp_pkgs_source = ENVIRON["TECHLIB_PKGS"] 
  split(tlp_pkgs_source, pkgs_path, ":")
  for (i in pkgs_path) {
      pkgs_file=pkgs_path[i]"/"fname
#      DEBUG("Checking file :"pkgs_file)
      if (system("test -e "pkgs_file)==0) {
#         DEBUG("Package Found :"pkgs_file)
         return pkgs_file
      }
  }
#  DEBUG("Package Not Found :"fname)
  return ""
}

BEGIN {
  print "--------------------------------------------------------"
  print "[tlp_import]: BEGIN "
  print "--------------------------------------------------------"
  tlp_pkgs_source = ENVIRON["TECHLIB_PKGS"] 
  if (tlp_pkgs_source == "") {
      tlp_pkgs_source = "."
  }

  tlp_pkgs_config = ENVIRON["TECHLIB_CFGS"] 
  if (tlp_pkgs_config == "") {
      tlp_pkgs_config = "."
  }
  
  tlp_reln_root = ENVIRON["TECHLIB_RELN"] 
  if (tlp_reln_root == "") {
      tlp_reln_root = "releaseNotes"
  }
  tlp_install_root = ENVIRON["TECHLIB_HOME"]
  if (tlp_install_root == "") {
      tlp_install_root = "techLib"
  }

  tlp_import_option= ENVIRON["TLP_PACK_OPTION"]
  split(tlp_import_option, tlp_options)
  for (option in tlp_options) {
      if (option == "--verbose") {
         mode_verbose = 1
      } else if (option == "--info") {
         mode_info = 1
      } else if (option == "--skip_topdir") {
         skip_topdir = 1
      } else {
      }
  }
    
  tlp_totoal   = 0
  tlp_created   = 0
  tlp_skipped  = 0
  tlp_modified = 0
  tlp_pkgs_err = 0
}

BEGINFILE {
  tlp_total++
  HILITE("["tlp_total"]: Reading '"FILENAME"' ...")
  tlp_format    = "1.0"
  kit_node      = _
  kit_pdk       = _
  kit_group     = _
  kit_type      = _
  kit_version   = _
  kit_orgin     = _
  kit_topdir    = _
  kit_size      = _
  kit_md5sum    = _

  base_num      = 0
  file_num      = 0
  pkgs_file_missing = 0
}
/^#/ { next }
/^TLP\s+FORMAT\s/	{ tlp_format = $3 }
/^TLP\s+END\s/		{ nextfile }

/^KIT\s+NODE\s/      { kit_node = $3 }
/^KIT\s+PDK\s/       { kit_pdk  = $3 }
/^KIT\s+GROUP\s/     { kit_group = $3 }
/^KIT\s+TYPE\s/      { kit_type = $3 }
/^KIT\s+TOPDIR\s/    { kit_topdir = $3 }
/^KIT\s+VERSION\s/   { kit_version = $3 }
/^KIT\s+ORIGIN\s/    { kit_origin = $3 }
/^KIT\s+SIZE\s/      { kit_size = $3 }


/^PACKAGE\s+TARGET\s/ { 
  tlp_package_dir = $3 
}
/^PACKAGE\s+BASE\s/  {
    base_num++ 
    pkgs_base[base_num]=$3
    tlp_pkgs_base = tlp_pkgs_config"/"pkgs_base[base_num]".tlp"
    if (system("test -e "tlp_pkgs_base) != 0) {
       pkgs_file_missing++
       PRINT("    : Install base - "pkgs_base[base_num]" can not be found in package source.")
    } else {
       print "    : Install base - "tlp_pkgs_base
    }
}
/^PACKAGE\s+(FILE|PATCH)\s/  {
    file_num++
    file_lst[file_num]=$3
    file_top[file_num]=$4
    file_md5[file_num]=$5
    file_tgz[file_num]=find_tlp_package($3)
    if (file_tgz[file_num] == "") {
       pkgs_file_missing++
       PRINT("    : Pacakge file - "file_lst[file_num]" can not be found in package source.")
    } else {
       print "    : Package file - "file_tgz[file_num]
    }
}


ENDFILE {
  if (verbose_mode == 1) {
     print "TLP FORMAT    "tlp_format
     print "KIT NODE      "kit_node
     print "KIT PDK       "kit_pdk
     print "KIT GROUP     "kit_group
     print "KIT TYPE      "kit_type
     print "KIT VERSION   "kit_version
     print "KIT ORIGIN    "kit_origin
     print "KIT TOPDIR    "kit_topdir
     print "KIT MD5SUM    "kit_md5sum
     print "TLP END"
  }
  if (skip_topdir == 1) {
     reln_dir = kit_node"/"kit_pdk"/"kit_group"/"kit_type
  } else {
     reln_dir = kit_node"/"kit_pdk"/"kit_group"/"kit_type"/"kit_topdir
  }
  "basename "FILENAME" .tlp" | getline tlp_basename
  reln_file = reln_dir"/"tlp_basename".releaseNote"

  if (pkgs_file_missing) {
     ERROR("Kit '"tlp_basename"' has "pkgs_file_missing" missing pacakge files")
     tlp_pkgs_err++
  } else if (system("test -e "tlp_reln_root"/"reln_file) == 0) {
     WARNING("Skip import "reln_file" (already exist)")
     if (system("diff "tlp_reln_root"/"reln_file" "FILENAME) !=0) {
        WARNING("Kit '"tlp_basename"' in the DK_RELN has been modified")
        tlp_modified++
     }
     tlp_skipped++
  } else {
     print "    : Creating '"reln_file"' ("kit_version")"
     system("mkdir -p "tlp_reln_root"/"reln_dir)
     system("cp -f "FILENAME" "tlp_reln_root"/"reln_file)
     tlp_created++
     print kit_node" "kit_pdk" "kit_group" "kit_type"\t"tlp_basename" "kit_topdir" "kit_version" "kit_origin >> tlp_reln_root"/.tlp_package_info.csv"
  }
  print ""
}

END {
  print "\033[1m\033[34m"
  print "------------------------------------------------------------------"
  print "[tlp_import]: Total "tlp_created"/"tlp_total" tlp release notes are created." 
  if (tlp_pkgs_err) {
  print "[tlp_import]: Total "tlp_pkgs_err"/"tlp_total" tlp files have missing package files. (error)"
  }
  if (tlp_skipped) {
  print "[tlp_import]: Total "tlp_skipped"/"tlp_total" tlp files are skipped. (exist)"
  }
  if (tlp_modified) {
  print "[tlp_import]: Total "tlp_modified"/"tlp_skipped" existing tlp files are modified.(warning)"
  }
  print "------------------------------------------------------------------"
  print "\033[0m"
}
