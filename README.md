# TechLib Package Management Kit V2020_0410a

## Define the following environment variables in the shell:

	TECHLIB_PKGS	- package source directory (*.tgz and *.tlp)
	TECHLIB_DOCS	- data sheet respository directory (sorted collection)
	TECHLIB_ROOT  	- target techLib directory (where you plan to install)

Directory:
<pre>
	$(TECHLIB_ROOT)/
		+-- $(NODE)
			+--- $(MVER)
				+-- $(GROUP)
</pre>					+----- $(NAME)
Example:
<pre>
	techLib/
		+-- T28HPC/
			+----- 0p5/
			|	+----- FDK
			|		+----- PDK
			|		+----- CTK
			+----- 0p9/
				+----- FDK
				|	+----- PDK
				+----- FIP
					+----- STDCELL
</pre>

## Step 0：Prepare TechLib Package definition file:

Example:
	
	::::::::::::::
	STDCELL_lib222_7t_base_e.2.0.tlp
	::::::::::::::
	BEGIN	TLP
	NODE	T28HPC
	MVER	0p5
	GROUP	FIP
	TYPE	STDCELL
	KITNAME	7t_base_e.2.0
	ORIGIN	7t_base_e.1.1
	DIRNAME	lib222_7t_base_e20
	SIZE	10000
	MD5SUM	11ba9bfa12c16459bc242c005c351b6f

	REQUIRE	KIT	T28HPC/0p5/FDK/PDK	TOPDIR	pdk222_r10HF7

	; If the kit size is huge, it could be split to multiple package files
	PACKAGE	FILE	STDCELL_lib222_7t_base_e.2.0-1.tgz  
	PACKAGE	FILE	STDCELL_lib222_7t_base_e.2.0-2.tgz  
	PACKAGE	FILE	STDCELL_lib222_7t_base_e.2.0-3.tgz  

	END 
	; below this line, there are human readable docs which will be ignored by tool

## Step 1: Import TechLib Package to data sheet repository:

	% tlp_import [--packageSrcDir $TECHLIB_PKGS] [--dataSheetDir $TECHLIB_DOCS]

	% tlp_import <package>.tlp ...

	1. Search TLP definition file (*.tlp) in TECHLIB_PKGS directory 
	2. Copy the TLP definition file to $TECHLIB_DOCS directory as a dataSheet(dts) file
	   and categorize the dataSheet (dts) files based on tech node.

  Example:

	dataSheets/
		|
		+-- T28HPC
			|
			+----- 0p5
			|	|
			|	+----- FDK
			|		|
			|		+----- PDK
			|		|	+---- aaa.dts
			|		|
			|		+----- CTK
			|			+---- bbb.dts
			+----- 0p9
				|
				+----- FDK
				|	|
				|	+----- PDK
				|		+---- ccc.dts
				+----- FIP
					|
					+----- STDCELL
						+---- ddd.dts
						+---- eee.dts


## Step 2: Install selected packages into techlib directory:

  Usage-1 (Package Name):

	% tlp_install <packageName> ...  ; search the tlp from $TECHLIB_PKGS

	% tlp_install <directoryPath>/<packageName>.tlp ...


  Usage-2 (Bundle File):

	% tlp_install --bundleFile <packageBundleListFile>

	  Search the package definition file and tar kit in $TECHLIB_PKGS and install 
	all packages following the sequence. If any package fail to be installed,
	the process will stop. After fixing the problem, teh same bundleFile could
	be used, and package installtion will continue.

  Example:

	packageName1
	packageName2
	packageName3


  Usage-3 (Interactive):

	% tlp_install [--dataSheetDir $TECHLIB_DOCS] [--selectByCategory NODE/MVER/GROUP/TYPE]

	User can specify kit category and then select the packages.
	The tool will list all release notes of selected category under $TECHLIB_DOCS directory:

  Example:

	% tlp_install [--dataSheetDir $TECHLIB_DOCS] --selectByCategory T28HPC/0p9

	INFO: Cateogry - [T28HPC/0p9] 

		1) FDK/PDK/ccc
		2) FIP/STDCELL/ddd
		3) FIP/STDCELL/eee

	QUESTION: Which packages would you like to install? 1 3

	INFO: Installing designkit package "ccc" ..
	INFO: Validating package integrity ...
	INFO: Checking package dependcy ...
	INFO: Unpacking package files "ccc-1.tgz" ...
	INFO: Unpacking package files "ccc-2.tgz" ...

	INFO: Installing designkit package "eee" ..
	...

  Logfle:

	tlp_install.log  =>  detail installation log 
	$TECHLIB_ROOT/.tlp_install.summar         => pacakge installation tracking summary
	$TECHLIB_ROOT/<NODE>/<MVER>/.tlp_packages  => package list which has been installed


## Step 3: Verify post-installation check (NOT IMPLEMETNTED YET)

	% tlp_check <installed_kit_topdir>    (<NODE>/<MVER>/<GROUP>/<TYPE>/<kit_top_dir>)

	% tlp_check --bundleFile <packageBundleListFile>

	% tlp_check [--targetLibDir $TECHLIB_ROOT] --techNode <NODE/MVER>

