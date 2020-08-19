#!/usr/bin/gawk -f
function HEADER(message)  { print "\033[34;40m"message"\033[0m" }
function HILITE(message)  { print "\033[1m"message"\033[0m" }
function WARNING(message) { print "\033[34mWARNING: "message"\033[0m" }
function ERROR(message)   { print "\033[31;43mERROR: "message"\033[0m" }
function PRINT(message)   { print "\033[31m"message"\033[0m" }
function DEBUG(message)   { print "\033[35mDEBUG: "message"\033[0m" }
function find_tlp_package(fname) {
  pkgs_file=""
  tlp_pkgs_source = ENVIRON["TECHLIB_PKGS"] 
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
  print "[tlp_install]: BEGIN "
  print "--------------------------------------------------------"
  tlp_install_root = ENVIRON["TECHLIB_ROOT"]
  if (tlp_install_root == "") {
      tlp_install_root = "techLib"
  }
  tlp_install_summary = tlp_install_root"/.tlp_install.summary"
  if ((system("mkdir -p "tlp_install_root"/.tlp_install/") != 0) ||
      (system("touch "tlp_install_summary) != 0)) {
      ERROR("no write permission on '"tlp_install_root"'.")
      exit -1
  }
  
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


  tlp_install_option= ENVIRON["TECHLIB_OPTION"]
  split(tlp_install_option, tlp_options)
  for (option in tlp_options) {
      if (option == "--verbose") {
         mode_verbose = 1
      } else if (option == "--info") {
         mode_info = 1
      } else {
      }
  }
  
  tlp_install_temp = ENVIRON["TECHLIB_TEMP"]
  
  tlp_totoal   = 0
  tlp_created  = 0
  tlp_skipped  = 0
  tlp_conflict = 0
  tlp_modified = 0
  tlp_reqs_err = 0
  tlp_pkgs_err = 0
  
  color_warn = "\033[33m"
  color_err  = "\033[31m"
  color_off  = "\033[0m"
}

BEGINFILE {
  tlp_total++
  HILITE("["tlp_total"]: Reading '"FILENAME"' ...")
  tlp_format    = "1.0"
  process_node      = _
  model_vers       = _
  kit_group     = _
  kit_type      = _
  kit_name   = _
  kit_orgin     = _
  kit_srcdir    = _
  kit_size      = _
  kit_md5sum    = _
  
  tlp_package_type = "FULL"

  kit_already_exist = 0
  kit_require_fail = 0
  
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

/^NODE\s/      { process_node = $2 }
/^MVER\s/     { model_vers  = $2 }
/^CATG\s/     { kit_group = $2 }
/^TYPE\s/      { kit_type = $2 }
/^SDIR\s/      { kit_srcdir = $2 }
/^SIZE\s/      { kit_size = $2 }
/^MD5S\s/      { kit_md5sum = $2 }

/^DEPN\s+KIT=/ {
  req_kit_name = $3
  if ((req_kit_name != "_") && (req_kit_name != "-")) {
     if (system("test -e "tlp_install_root"/.tlp_install/"req_kit_name".tlp") != 0) {
        PRINT("    : Required kit '"req_kit_name"' has not been installed yet.")
        kit_require_fail++
     }
  }
}

/^DEPN\s+DIR=/ {
  req_kit_dir = $3
  if ((req_kit_dir != "_") && (req_kit_dir != "-")) {
     if (system("test -e "tlp_install_root"/"req_kit_dir) != 0) {
        PRINT("    : Required kit dir '"req_kit_dir"' has not been installed yet.")
        kit_require_fail++
     }
  }
}


/^DEPN\s+KIT\s/ {
  req_kit_type = $3
  if (req_kit_name != "_") {
     if ($4 == "TOPDIR") {
        req_kit_dir = req_kit_type"/"$5
        if (system("test -e "tlp_install_root"/"req_kit_dir) != 0) {
           PRINT("    : Required kit dir '"req_kit_dir"' has not been installed yet.")
           kit_require_fail++
        }
     }
  }
}

  /^TDIR\s/ { 
  tlp_package_dir = $3 
}
/^REQU\s/  {
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
/^(FILE|FULL|MULTI|PATCH)\s/  {
    file_num++
    file_pack[file_num]=$2
    file_lst[file_num]=$3
    file_top[file_num]=$4
    file_md5[file_num]=$5
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
     print "BEGIN     TLP"tlp_format
     print "NAME      "kit_name
     print "ORIG      "kit_origin
     print "NODE      "process_node
     print "MVER      "model_vers
     print "CATG      "kit_group
     print "TYPE      "kit_type
     print "SDIR      "kit_srcdir
     print "SIZE      "kit_size
     print "MD5S      "kit_md5sum
     print "END"
  }
  process_dir = process_node"/"model_vers
  category_dir = process_node"/"model_vers"/"kit_group"/"kit_type
  "basename "FILENAME" .dts" | getline BASEFILE
  "basename "BASEFILE" .tlp" | getline kit_name
  tlp_install_dir = tlp_install_root"/"category_dir

  if (system("test -e "tlp_install_dir"/"kit_srcdir) == 0) {
     if (system("test -f "tlp_install_dir"/"kit_srcdir"/"kit_name".dts") == 0) {
        WARNING("Skip install '"kit_name"' (already installed)")
        tlp_skipped++
        kit_already_exist = 1
     } else if (tlp_package_type == "FULL") {
        ERROR("Kit directory '"kit_srcdir"' already exist before installing full kit package.")
        tlp_conflict++
        kit_already_exist = 1
     } else {
        print "    : Directory '"tlp_install_dir"/"kit_srcdir"' already exist."
     }
  } else {
     if (tlp_package_type == "PATCH") {
        WARNING("Base directory '"kit_srcdir"' is missing for patch package.")
     }
  }
  if (kit_already_exist) {
  } else if (kit_require_fail) {
     ERROR("Can not install '"kit_name"' (dependency fail)")
     tlp_reqs_err++
  } else if (pkgs_file_missing) {
     ERROR("Can not install '"kit_name"' (missing pacakge)")
     tlp_pkgs_err++
  } else {
     system("mkdir -p "tlp_install_dir"/"kit_srcdir)
     system("cp -f "FILENAME" "tlp_install_dir"/"kit_srcdir"/"kit_name".dts")
     system("ln -fs ../"category_dir"/"kit_srcdir"/"kit_name".dts "tlp_install_root"/.tlp_install/"kit_name".tlp")
     system("echo \"`date +%Y%m%d_%H%M%S` `whoami` % tlp_install "kit_name"\t;"FILENAME"\" >> "tlp_install_summary)
     if (i in pkgs_base) {
         tlp_pkgs_base = tlp_pkgs_config"/"pkgs_base[i]".tlp"
         print "INFO: Installing base kit '"tlp_pkgs_base"' ..."
         system("tlp_install "tlp_pkgs_base)
     }  
     for (i in file_tgz) {
        tlp_pkgs_file = file_tgz[i]
        print "INFO: Unpacking file '"tlp_pkgs_file"' ..."
        system("gunzip -c "tlp_pkgs_file" | (cd "tlp_install_dir"; tar xvf -)")
     }
     print kit_name >> tlp_install_root"/"process_dir"/.tlp_packages"
     tlp_created++
  }
  print ""
}

END {
  print "\033[1m\033[34m"
  print "------------------------------------------------------------------"
  if (tlp_created) {
  print "[tlp_install]: Total "tlp_created"/"tlp_total" kits are installed."
  }
  if (tlp_skipped) {
  print "[tlp_install]: Total "tlp_skipped"/"tlp_total" kits are skipped. (already exist)"
  }
  if (tlp_conflict) {
  print "[tlp_install]: Total "tlp_conflict"/"tlp_total" kits have conflict root. (error)"
  }
  if (tlp_reqs_err) {
  print "[tlp_install]: Total "tlp_reqs_err"/"tlp_total" kits require check fail. (error)"
  }
  if (tlp_pkgs_err) {
  print "[tlp_install]: Total "tlp_pkgs_err"/"tlp_total" kits have missing package files. (error)"
  }
  print "------------------------------------------------------------------"
  print "\033[0m"
}
 