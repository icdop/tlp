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
  tlp_install_root = ENVIRON["TECHLIB_HOME"]
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
  
  
  tlp_reln_root = ENVIRON["TECHLIB_RELN"] 
  if (tlp_reln_root == "") {
      tlp_reln_root = "releaseNotes"
  }


  tlp_install_option= ENVIRON["TLP_INSTALL_OPTION"]
  split(tlp_install_option, tlp_options)
  for (option in tlp_options) {
      if (option == "--verbose") {
         mode_verbose = 1
      } else if (option == "--info") {
         mode_info = 1
      } else {
      }
  }
  
  tlp_intall_temp = ENVIRON["TLP_INSTALL_TEMP"]
  
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
  kit_node      = _
  kit_pdk       = _
  kit_group     = _
  kit_type      = _
  kit_version   = _
  kit_orgin     = _
  kit_topdir    = _
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
/^KIT\s+MD5SUM\s/    { kit_md5sum = $3 }

/^REQUIRE\s+SKU\s/ {
  req_kit_SKU = $3
  if ((req_kit_SKU != "_") && (req_kit_SKU != "-")) {
     if (system("test -e "tlp_install_root"/.tlp_install/"req_kit_SKU".tlp") != 0) {
        PRINT("    : Required kit SKU '"req_kit_SKU"' has not been installed yet.")
        kit_require_fail++
     }
  }
}

/^REQUIRE\s+DIR\s+(\S+)/ {
  req_kit_dir = $3
  if ((req_kit_dir != "_") && (req_kit_dir != "-")) {
     if (system("test -e "tlp_install_root"/"req_kit_dir) != 0) {
        PRINT("    : Required kit dir '"req_kit_dir"' has not been installed yet.")
        kit_require_fail++
     }
  }
}


/^REQUIRE\s+KIT\s/ {
  req_kit_type = $3
  if (req_kit_SKU != "_") {
     if ($4 == "TOPDIR") {
        req_kit_dir = req_kit_type"/"$5
        if (system("test -e "tlp_install_root"/"req_kit_dir) != 0) {
           PRINT("    : Required kit dir '"req_kit_dir"' has not been installed yet.")
           kit_require_fail++
        }
     }
  }
}

/^PACKAGE\s+TYPE\s/ { 
  tlp_package_type = $3 
  if ($3 != "FULL") {
       print "    : Package type - "tlp_package_type
  }
}
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
/^PACKAGE\s+(FILE|FULL|MULTI|PATCH)\s/  {
    file_num++
    file_pack[file_name]=$2
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
     print "KIT SIZE      "kit_size
     print "KIT MD5SUM    "kit_md5sum
  }
  process_dir = kit_node"/"kit_pdk
  category_dir = kit_node"/"kit_pdk"/"kit_group"/"kit_type
  "basename "FILENAME" .releaseNote" | getline BASEFILE
  "basename "BASEFILE" .tlp" | getline kit_SKU
  tlp_install_dir = tlp_install_root"/"category_dir

  if (system("test -e "tlp_install_dir"/"kit_topdir) == 0) {
     if (system("test -f "tlp_install_dir"/"kit_topdir"/"kit_SKU".releaseNote") == 0) {
        WARNING("Skip install '"kit_SKU"' (already installed)")
        tlp_skipped++
        kit_already_exist = 1
     } else if (tlp_package_type == "FULL") {
        ERROR("Kit directory '"kit_topdir"' already exist before installing full kit package.")
        tlp_conflict++
        kit_already_exist = 1
     } else {
        print "    : Directory '"tlp_install_dir"/"kit_topdir"' already exist."
     }
  } else {
     if (tlp_package_type == "PATCH") {
        WARNING("Base directory '"kit_topdir"' is missing for patch package.")
     }
  }
  if (kit_already_exist) {
  } else if (kit_require_fail) {
     ERROR("Can not install '"kit_SKU"' (dependency fail)")
     tlp_reqs_err++
  } else if (pkgs_file_missing) {
     ERROR("Can not install '"kit_SKU"' (missing pacakge)")
     tlp_pkgs_err++
  } else {
     system("mkdir -p "tlp_install_dir"/"kit_topdir)
     system("cp -f "FILENAME" "tlp_install_dir"/"kit_topdir"/"kit_SKU".releaseNote")
     system("ln -fs ../"category_dir"/"kit_topdir"/"kit_SKU".releaseNote "tlp_install_root"/.tlp_install/"kit_SKU".tlp")
     system("echo \"`date +%Y%m%d_%H%M%S` `whoami` % tlp_install "kit_SKU"\t;"FILENAME"\" >> "tlp_install_summary)
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
     print kit_SKU >> tlp_install_root"/"process_dir"/.tlp_packages"
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
  print "[tlp_install]: Total "tlp_conflict"/"tlp_total" kits have conflict topdir. (error)"
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
