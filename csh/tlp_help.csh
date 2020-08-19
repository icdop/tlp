#!/bin/csh -f
set prog = $0:t
if (($1 == "")||($1 == "-h")||($1 == "--help")) then
   echo "Usage: $prog [name]"
   echo "  run     - copy testcsae 'run/01_case'"
   echo "  env     - show tlp environment variables"
   echo "  command - show tlp available commands"
   echo "  readme  - README.md"
   echo "  start   - quick starter guide"
   echo "  format  - docs/TLP_FORMAT.md"
   echo "  example - docs/TLP_EXAMPLE.txt"
   echo ""
   exit -1
endif
if ($?TLP_HOME == 0) then
   setenv TLP_HOME $0:h/..
endif

switch($1)
  case "command":
    foreach cmd (tlp_import tlp_install tlp_check)
      echo "======================================================="
      $cmd --help
    end
    breaksw
  case "env"
    echo "TECHLIB_ROOT = $TECHLIB_ROOT"
    echo "TECHLIB_DOCS = $TECHLIB_DOCS"
    echo "TECHLIB_PKGS = $TECHLIB_PKGS"
    breaksw
  case "readme":
    more $TLP_HOME/README.md
    breaksw
  case "start":
    xpdf $TLP_HOME/docs/TLP_QuickStart.pdf &
    breaksw
  case "format":
    more $TLP_HOME/docs/TLP_FORMAT.md
    breaksw
  case "example":
    more $TLP_HOME/docs/TLP_EXAMPLE.txt
    breaksw
  case "run":
  case "testcase":
    echo "INFO: copy testcase to run/ .."
    echo "INFO: % cd run/01_case; make help"
    cp -fr $TLP_HOME/run .
    cd run/01_case; make help
    breaksw
  case "project":
    echo "INFO: copy project to project/ .."
    cp -fr $TLP_HOME/project .
    cd project; ls -al
    breaksw
  case "update":
    (cd $TLP_HOME; svn update . ; svn ci . -m '$2')
    breaksw
  default:
    echo "ERROR: $1 command not support"
endsw
