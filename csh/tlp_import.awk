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
  
  tlp_docs_root = ENVIRON["TECHLIB_DOCS"] 
  if (tlp_docs_root == "") {
      tlp_docs_root = "dataSheets"
  }
  tlp_install_root = ENVIRON["TECHLIB_ROOT"]
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
      } else if (option == "--skip_root") {
         skip_root = 1
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
  kit_node      = _
  model_vers       = _
  kit_group     = _
  kit_type      = _
  kit_name   = _
  kit_orgin     = _
  kit_srcdir    = _
  kit_size      = _
  kit_md5sum    = _

  base_num      = 0
  file_num      = 0
  pkgs_file_missing = 0
}
/^#/ { next }
/^BEGIN\s+TLP\s/	{ 
  if ($3 == "") {
      tlp_package_type = "FULL"
  } else {
      tlp_package_type = $3
      print "    : Package type - "tlp_package_type
  }
}

/^END\s/		{ nextfile }

/^NAME\s/    { kit_name = $2 }
/^ORIG\s/    { kit_origin = $2 }

/^NODE\s/      { process_node  = $2 }
/^MVER\s/      { model_vers  = $2 }
/^CATG\s/     { kit_group = $2 }
/^TYPE\s/      { kit_type = $2 }
/^SDIR\s/      { kit_srcdir = $2 }
/^SIZE\s/      { kit_size = $2 }
/^MD5S\s/      { kit_md5sum = $2 }

/^TDIR\s/ { 
  tlp_package_dir = $2
}
/^(REQU|REQUIRE)\s/  {
    base_num++ 
    pkgs_base[base_num]=$2
    tlp_pkgs_base = tlp_pkgs_config"/"pkgs_base[base_num]".tlp"
    if (system("test -e "tlp_pkgs_base) != 0) {
       pkgs_file_missing++
       PRINT("    : Install base - "pkgs_base[base_num]" can not be found in package source.")
    } else {
       print "    : Install base - "tlp_pkgs_base
    }
}
/^(FILE|PATCH)\s/  {
    file_num++
    file_lst[file_num]=$2
    file_top[file_num]=$3
    file_md5[file_num]=$4
    file_tgz[file_num]=find_tlp_package($2)
    if (file_tgz[file_num] == "") {
       pkgs_file_missing++
       PRINT("    : Pacakge file - "file_lst[file_num]" can not be found in package source.")
    } else {
       print "    : Package file - "file_tgz[file_num]
    }
}


ENDFILE {
  if (verbose_mode == 1) {
     print "BEGIN     TLP "tlp_package_type
     print "NAME      "kit_name
     print "ORIG      "kit_origin
     print "NODE      "process_node
     print "MVER      "process_vers
     print "CATG      "kit_group
     print "TYPE      "kit_type
     print "SDIR      "kit_srcdir
     print "SIZE      "kit_size
     print "MD5S      "kit_md5sum
     print "END"
  }
  if (skip_root == 1) {
     docs_dir = process_node"/"model_vers"/"kit_group"/"kit_type
  } else {
     docs_dir = process_node"/"model_vers"/"kit_group"/"kit_type"/"kit_srcdir
  }
  "basename "FILENAME" .tlp" | getline tlp_basename
  docs_file = docs_dir"/"tlp_basename".dts"

  if (pkgs_file_missing) {
     ERROR("Kit '"tlp_basename"' has "pkgs_file_missing" missing pacakge files")
     tlp_pkgs_err++
  } else if (system("test -e "tlp_docs_root"/"docs_file) == 0) {
     WARNING("Skip import "docs_file" (already exist)")
     if (system("diff "tlp_docs_root"/"docs_file" "FILENAME) !=0) {
        WARNING("Kit '"tlp_basename"' in the DK_RELN has been modified")
        tlp_modified++
     }
     tlp_skipped++
  } else {
     print "    : Creating '"docs_file"' ("kit_name")"
     system("mkdir -p "tlp_docs_root"/"docs_dir)
     system("cp -f "FILENAME" "tlp_docs_root"/"docs_file)
     tlp_created++
     print process_node" "model_vers" "kit_group" "kit_type"\t"tlp_basename" "kit_srcdir" "kit_name" "kit_origin >> tlp_docs_root"/.tlp_package_info.csv"
  }
  print ""
}

END {
  print "\033[1m\033[34m"
  print "------------------------------------------------------------------"
  print "[tlp_import]: Total "tlp_created"/"tlp_total" tlp data sheets are created." 
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
