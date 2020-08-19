
function HEADER(message)  { print "\033[34;40m"message"\033[0m" }
function HILITE(message)  { print "\033[1m"message"\033[0m" }
function WARNING(message) { print "\033[34mWARNING: "message"\033[0m" }
function ERROR(message)   { print "\033[31;43mERROR: "message"\033[0m" }
function PRINT(message)   { print "\033[31m"message"\033[0m" }
function DEBUG(message)   { print "\033[35mDEBUG: "message"\033[0m" }

BEGIN {
  print "--------------------------------------------------------"
  print "[tlp_pack]: BEGIN"
  print "--------------------------------------------------------"

  tlp_pkgs_cfgs = ENVIRON["TLP_CFGS_DEST"] 
  if (tlp_pkgs_cfgs == "") {
      tlp_pkgs_cfgs = "configs"
  }

  tlp_pkgs_dest = ENVIRON["TLP_PKGS_DEST"] 
  if (tlp_pkgs_dest == "") {
      tlp_pkgs_dest = "packages"
  }

  tlp_pack_root = ENVIRON["TECHLIB_TEMP"]
  if (tlp_pack_root == "") {
      tlp_pack_root = "tempLib"
  }

  tlp_pack_option= ENVIRON["TECHLIB_OPTION"]
  split(tlp_pack_option, tlp_options)
  for (option in tlp_options) {
      if (option == "--verbose") {
         option_verbose = 1
      } else if (option == "--info") {
         option_info = 1
      } else if (option == "--test") {
         option_test = 1
      } else {
      }
  }
  


}
BEGINFILE {
  print "\033[34m"
  HILITE("[tlp_pack]: Processing TechLib Package file '"FILENAME"' ...")
  "basename "FILENAME" .csv" | getline bundleFile
  bundleFile = bundleFile".bundle"
  system("echo -n > "bundleFile)

  tlp_format = ""
  tlp_test_mode = 0
  
  process_node   = "_"
  model_vers    = "_"
  kit_group  = "_"
  kit_type   = "_"
  kit_srcdir = "_"
  kit_name = "_"
  kit_origin  = "_"
  kit_location = "_"
  kit_content   = ""
  
  req_kit_SKU = "_"
  req_kit_type = "_"

  tlp_pkgs_total   = 0  
  tlp_pkgs_created = 0
  tlp_pkgs_error   = 0  

}

/^#/ {}
/^BEGIN\s+PACKAGE\s/	{ tlp_format = $3 }
/^MODE\s+TEST/		{ tlp_test_mode = 1 }
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

/^DEPN\s/ {
  if ($2 == "KIT") {
     req_kit_type = $3
     if ($4 == "TOPDIR") {
        req_kit_srcdir = $5
     } else if ($4 == "VERSION") {
        req_version = $5
     } else {
        req_kit_type = "_"
     }
  } else {
     req_kit_type = "_"
  }
}

/^(FULL|PATCH|MULTI)\s/ {
  tlp_pkgs_total++

  tlp_package_type = $1
  process_node = $2
  model_vers = $3
  kit_group = $4
  kit_type    = $5
  kit_name    = $6
  kit_srcdir  = $7
  kit_version = $8
  kit_depend  = $9
  kit_location = $10
  kit_content = $11

  HILITE("["tlp_pkgs_total"]: Packing Kit '"kit_name"' ...")
  category_dir = process_node"/"model_vers"/"kit_group"/"kit_type

  system("mkdir -p "tlp_pkgs_cfgs)
  system("mkdir -p "tlp_pkgs_dest)
  kit_tlp = tlp_pkgs_cfgs"/"kit_name".tlp"
  kit_tgz = tlp_pkgs_dest"/"kit_name".tgz"

     print "BEGIN\tTLP\t"tlp_package_type	> kit_tlp
     print "" >> kit_tlp
     print "NAME\t"kit_name	>> kit_tlp
     print "ORIG\t"kit_origin	>> kit_tlp
     print "NODE\t"process_node	>> kit_tlp
     print "MVER\t"model_vers	>> kit_tlp
     print "CATG\t"kit_group	>> kit_tlp
     print "TYPE\t"kit_type	>> kit_tlp
     print "SDIR\t"kit_srcdir	>> kit_tlp
     print "" >> kit_tlp

     if ((kit_depend != "_") && (kit_depend != "-")){
        if (kit_depend != kit_name) {
           print "DEPN\t"kit_depend >> kit_tlp
        }
     }

     if ((req_kit_type != "_") && (req_kit_type != "-")) {
        if ((pack_type == "PATCH") || (req_kit_srcdir != kit_srcdir)) {
           print "DEPN\t"req_kit_type"\tTOPDIR\t"req_kit_srcdir >> kit_tlp
        }
     }
  tlp_pack_dir = tlp_pack_root"/"category_dir
  system("mkdir -p "tlp_pack_dir"/"kit_srcdir)
     
#  print "PACKAGE\tTYPE\t"pack_type	>> kit_tlp
  file_type = "FILE"
  if (tlp_test_mode == 1) {
     print "       Create pseudo kit directory '"kit_srcdir"' ..."
     system("cp "kit_tlp" "tlp_pack_dir"/"kit_srcdir"/"kit_name".dts")
     system("(cd "tlp_pack_dir"; tar -c -O -z "kit_srcdir") > "tlp_pkgs_dest"/"kit_name"_test.tgz") 
     print "" >> kit_tlp
     print file_type"\t"kit_name"_test.tgz" >> kit_tlp
     print "" >> kit_tlp
     print "END" >> kit_tlp
  } else if ((kit_location == "")||(kit_location == "-")||(kit_location == "_")) {
     print "       Create TLP file only ..."
     print "" >> kit_tlp
     print file_type"\t"kit_name".tgz" >> kit_tlp
     print "" >> kit_tlp
     print "END" >> kit_tlp
  } else if (pack_type == "MULTI") {
     "ls -1 "kit_location"/*.tgz" | getline pkgs_files
     print "" >> kit_tlp
     print file_type"\t"pkgs_files >> kit_tlp
     print "" >> kit_tlp
     print "END" >> kit_tlp
  } else if (system("test -f "kit_location) == 0) {
     print "       Use package file '"kit_location"' ..."
     print "" >> kit_tlp
     print file_type"\t"kit_location >> kit_tlp
     print "" >> kit_tlp
     print "END" >> kit_tlp
  } else if (system("test -d "kit_location) == 0) {
     if (kit_content == "") { kit_content = "." }
     "basename "kit_location"" | getline kit_dir_base
     if (kit_dir_base == kit_srcdir) {
        print "       Create package file '"kit_name".tgz' .."
        #print "(cd "kit_location"/..; tar -c -O -z "kit_srcdir") > "kit_tgz
        system("(cd "kit_location"/..; tar -c -O -z "kit_srcdir") > "kit_tgz) 
     } else {
        print "       Copy designkit to kit directory '"kit_srcdir"' ..."
        #print "(cd "kit_location"; tar -c -O "kit_content" )|( cd "tlp_pack_dir"/"kit_srcdir"; tar -x )"
        system("(cd "kit_location"; tar -c -O "kit_content" )|( cd "tlp_pack_dir"/"kit_srcdir"; tar -x )")
        print "       Create package file '"kit_name".tgz' .."
        #print "(cd "tlp_pack_dir"; tar -c -O -z "kit_srcdir") > "kit_tgz
        system("(cd "tlp_pack_dir"; tar -c -O -z "kit_srcdir") > "kit_tgz) 
     }
     print "" >> kit_tlp
     print ""file_type"\t"kit_name".tgz" >> kit_tlp
     print "" >> kit_tlp
     print "END" >> kit_tlp
     "md5sum "kit_tgz | getline tgz_md5sum
  } else {
     ERROR("Kit directory '"kit_location"' does not exist.")
     system("rm -fr "tlp_pack_dir"/"kit_srcdir)
     tlp_pkgs_error++
  }
  if (system("test -d "tlp_pack_dir"/"kit_srcdir) == 0 ) {
     print kit_name > bundleFile
     system("rm -fr "tlp_pack_dir"/"kit_srcdir)
     tlp_pkgs_created++
  }
}

ENDFILE {
}
END {
  print "\033[1m\033[34m"
  print "--------------------------------------------------------"
  print "[tlp_pack]: Total "tlp_pkgs_created"/"tlp_pkgs_total" tlp packages are created." 
  if (tlp_pkgs_error) {
  print "[tlp_pack]: Total "tlp_pkgs_error"/"tlp_pkgs_total" tlp files have missing package files. (error)"
  }
  print "--------------------------------------------------------"
  print "\033[0m"
}
