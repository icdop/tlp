# TechLib Package Management Kit V2020_0410a

## Specify following environment variables in the shell:

	TECHLIB_PKGS	- package source directory (*.tgz and *.tlp)
	TECHLIB_RELN	- release note respository directory (sorted collection)
	TECHLIB_HOME	- target techLib directory (where you plan to install)

## Step 0：Prepare TechLib Package release note:

Example:
	
	::::::::::::::
	STDCELL_lib222_7t_base_e.2.0.tlp
	::::::::::::::
	TLP	FORMAT	1.0
	KIT	NODE	T28HPC
	KIT	PDK	0p5
	KIT	GROUP	FIP
	KIT	TYPE	STDCELL
	KIT	VERSION	7t_base_e.2.0
	KIT	ORIGIN	7t_base_e.1.1
	KIT	TOPDIR	lib222_7t_base_e20
	KIT	SIZE	10000
	KIT     MD5SUM	11ba9bfa12c16459bc242c005c351b6f

	REQUIRE	KIT	T28HPC/0p5/FDK/PDK	TOPDIR	pdk222_r10HF7

	; If the kit size is huge, it could be split to multiple package files
	PACKAGE	FILE	STDCELL_lib222_7t_base_e.2.0-1.tgz  
	PACKAGE	FILE	STDCELL_lib222_7t_base_e.2.0-2.tgz  
	PACKAGE	FILE	STDCELL_lib222_7t_base_e.2.0-3.tgz  

	TLP END 
	; below this line, there are human readable docs which will be ignored by tool

## Step 1: Import TechLib Package to release notes repository:

	% tlp_import [--packageSrcDir $TECHLIB_PKGS] [--releaseNoteDir $TECHLIB_RELN]

	% tlp_import <package>.tlp ...

	1. Search TLP definition file (*.tlp) in TECHLIB_PKGS directory 
	2. Copy the TLP definition file to $TECHLIB_RELN directory as a releaseNote file
	   and categorize the releaseNote files based on the collateral category.

  Example:

	releaseNotes/
		|
		+-- T28HPC
			|
			+----- 0p5
			|	|
			|	+----- FDK
			|		|
			|		+----- PDK
			|		|	+---- aaa.releaseNote
			|		|
			|		+----- CTK
			|			+---- bbb.releaseNote
			+----- 0p9
				|
				+----- FDK
				|	|
				|	+----- PDK
				|		+---- ccc.releaseNote
				+----- FIP
					|
					+----- STDCELL
						+---- ddd.releaseNote
						+---- eee.releaseNote


## Step 2: Install selected packages to techlib directory:

  Usage-1 (Package Name):

	% tlp_install <packageName> ...  ; search the tlp from $TECHLIB_PKGS
	% tlp_install <directoryPath>/<packageName>.tlp ...


  Usage-2 (Bundle File):

	% tlp_install --bundleFile <packageBundleListFile>

	  Search the package definition file and tar kit in $TECHLIB_PKGS and install 
	these package follow the sequence. If any package fail to be installed,
	the process will stop. After fixing the problem, same bundleFile could
	be used, package already installed will be kept as is.

  Example:

	packageName1
	packageName2
	packageName3


  Usage-3 (Interactive):

	% tlp_install [--releaseNoteDir $TECHLIB_RELN] [--selectByCategory NODE/PDK/GROUP/TYPE]

	User can specify kit category and then select the packages.
	The tool will list all release notes of selected category under $TECHLIB_RELN directory:

  Example:

	% tlp_install [--releaseNoteDir $TECHLIB_RELN] --selectByCategory T28HPC/0p9

	INFO: Cateogry - [T28HPC/0p9] 

		1) FDK/PDK/ccc
		2) FIP/STDCELL/ddd
		3) FIP/STDCELL/eee

	QUESTION: Which packages would you like to install? 1 3

	INFO: Installing collateral package "ccc" ..
	INFO: Validating package integrity ...
	INFO: Checking package dependcy ...
	INFO: Unpacking package files "ccc-1.tgz" ...
	INFO: Unpacking package files "ccc-2.tgz" ...

	INFO: Installing collateral package "eee" ..
	...

  Logfle:

	tlp_install.log  =>  detail installation log 
	$TECHLIB_HOME/.tlp_install.summar         => pacakge installation tracking summary
	$TECHLIB_HOME/<NODE>/<PDK>/.tlp_packages  => package list which has been installed


## Step 3: Verify post-installation check (NOT IMPLEMETNTED YET)

	% tlp_check <installed_kit_topdir>    (<NODE>/<PDK>/<GROUP>/<TYPE>/<kit_top_dir>)

	% tlp_check --bundleFile <packageBundleListFile>

	% tlp_check [--targetLibDir $TECHLIB_HOME] --techNode <NODE/PDK>

