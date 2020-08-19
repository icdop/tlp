# TLP utility testcase 1

  This testcase will guide you through the tlp release note validation prcocess
by importing tlp file into dataSheets/ directory. (make import)
  Then you can start install the designkit to the techLib/ directory using the
interactive installation method. (make install)
  At the end you can use the package log stored in the techLib to reproduce the
installation proceduce and make sure the result are consistent. (make bundle)

Step 0 - Check the designkit package and tlp config file :

	% make env

	==========================================
	TECHLIB_ROOT = techLib
	TECHLIB_CFGS = configs
	TECHLIB_PKGS = packages
	TECHLIB_DOCS = dataSheets
	==========================================


	% ls packages

	GPIO_lib222_e.0.6.1.tlp
	GPIO_lib222_e.0.6.1.tgz
	GPIO_lib222_e.0.6.tlp
	MEMORY_lib222_2PRF_e.0.6.tlp
	MEMORY_lib222_2PRF_e.0.6.tgz
	PT28HPCADF_r0.6.1.tlp
	PT28HPCADF_r0.6.1.tgz
	PT28HPCCTK_r0.6.1.tlp
	PT28HPCCTK_r0.6.1.tgz
	PT28HPCPDK_r0.6.1.tlp
	PT28HPCPDK_r0.6.1.tgz
	PT28HPCPDK_r1.0.1.tlp
	PT28HPCPDK_r1.0.1.tgz
	PT28HPCPDK_r1.0HF4.tlp
	PT28HPCPDK_r1.0HF4.tgz
	PT28HPCPDK_r1.0hf5.tgz
	PT28HPCPDK_r1.0hf6.tgz
	PT28HPCPDK_r1.0hf7.tlp
	PT28HPCPDK_r1.0hf7.tgz
	STDCELL_lib222_6t_base_e.1.0.tlp
	STDCELL_lib222_6t_base_e.1.0.tgz
	STDCELL_lib222_7t_base_e.2.0.tlp
	STDCELL_lib222_7t_base_e.2.0-1.tgz
	STDCELL_lib222_7t_base_e.2.0-2.tgz
	STDCELL_lib222_7t_base_e.2.0-3.tgz

***
Step 1 - Import the tlp configuration file to dataSheets directory :

	==========================
	% make import
	==========================
	CMDS: tlp_import --packageSrcDir packages --releaseNoteDir dataSheets --targetLibDir techLib
	TIME: @20171109_015748 BEGIN tlp_import
	[tlp_import]: BEGIN 
	[1]: Reading packages/GPIO_lib222_e.0.6.1.tlp
	    : Package file - packages/GPIO_lib222_e.0.6.1.tgz
	    : Creating 'T28HPC/0p5/HIP/GPIO/ip222_gpio_r061/GPIO_lib222_e.0.6.1.dts' (r0.6.1)

	[2]: Reading packages/GPIO_lib222_e.0.6.tlp
	ERROR: Pacakge GPIO_lib222_e.0.6.tgz can not be found in package source.    
	ERROR: Kit 'GPIO_lib222_e.0.6' has 1 missing pacakge files	<=== This is intended to show

	[3]: Reading packages/MEMORY_lib222_2PRF_e.0.6.tlp
	    : Package file - packages/MEMORY_lib222_2PRF_e.0.6.tgz
	    : Creating 'T28HPC/0p5/FIP/MEMORY/mem222_2prf_r061/MEMORY_lib222_2PRF_e.0.6.dts' (r0.6.1)

	.....
	.....
	[11]: Reading packages/STDCELL_lib222_7t_base_e.2.0.tlp
	    : Package file - packages/STDCELL_lib222_7t_base_e.2.0-1.tgz
	    : Package file - packages/STDCELL_lib222_7t_base_e.2.0-2.tgz
	    : Package file - packages/STDCELL_lib222_7t_base_e.2.0-3.tgz
	    : Creating 'T28HPC/0p5/FIP/STDCELL/lib222_7t_base_e20/STDCELL_lib222_7t_base_e.2.0.dts' (7t_base_e.2.0)
	
	------------------------------------------------------------------
	SUMMARY: Total 10/11 tlp release notes are created.
	SUMMARY: Total 1/11 tlp files have missing package files. (error)	<=== This is intended to show
	------------------------------------------------------------------
	[tlp_import]: END
	--------------------------------------------------------
	TIME: @20171109_015754 END   tlp_import
	========================================================


	==========================
	% tree dataSheets
	==========================

	dataSheets/
	└── T28HPC
	    └── 0p5
	        ├── FDK
	        │   ├── ADF
	        │   │   └── adf222_r061
	        │   │       └── PT28HPCADF_r0.6.1.dts
	        │   ├── CTK
	        │   │   └── ctk222_r061
	        │   │       └── PT28HPCCTK_r0.6.1.dts
	        │   └── PDK
	        │       ├── pdk222_r061
	        │       │   └── PT28HPCPDK_r0.6.1.dts
	        │       ├── pdk222_r101
	        │       │   └── PT28HPCPDK_r1.0.1.dts
	        │       ├── pdk222_r10HF4
	        │       │   └── PT28HPCPDK_r1.0HF4.dts
	        │       └── pdk222_r10HF7
	        │           └── PT28HPCPDK_r1.0hf7.dts
	        ├── FIP
	        │   ├── MEMORY
	        │   │   └── mem222_2prf_r061
        	│   │       └── MEMORY_lib222_2PRF_e.0.6.dts
	        │   └── STDCELL
	        │       ├── lib222_6t_base_e10
	        │       │   └── STDCELL_lib222_6t_base_e.1.0.dts
	        │       └── lib222_7t_base_e20
	        │           └── STDCELL_lib222_7t_base_e.2.0.dts
	        └── HIP
	            └── GPIO
	                └── ip222_gpio_r061
        	            └── GPIO_lib222_e.0.6.1.dts

	21 directories, 10 files

***
Step 2 - Install designkit package refer to dataSheets directory :

	==========================
	% make install           <= enter interactive mode if there is no input file specifed
	==========================

	==============================================================
	INFO: Please specify Kit Category :
	.
	└── T28HPC
	    └── 0p5
		├── FDK
		│   ├── ADF
		│   ├── CTK
		│   └── PDK
		├── FIP
		│   ├── MEMORY
		│   └── STDCELL
		└── HIP
		    └── GPIO

	11 directories
	INPUT: Category = () ? T28HPC/0p5/FDK
	
	==============================================================
	INFO: Current releaseNote directory: T28HPC/0p5/FDK
	dataSheets/T28HPC/0p5/FDK
	├── ADF
	│   └── adf222_r061
	├── CTK
	│   └── ctk222_r061
	└── PDK
	    ├── pdk222_r061
	    ├── pdk222_r101
	    ├── pdk222_r10HF4
	    └── pdk222_r10HF7

	9 directories, 6 files
	==============================================================
	INFO: Please select the following packages to be installed :
	[ dataSheets/T28HPC/0p5/FDK ]:
	  0) Go back to previous selection menu..
		1) PT28HPCADF_r0.6.1	(adf222_r061)
		2) PT28HPCCTK_r0.6.1	(ctk222_r061)
		3) PT28HPCPDK_r0.6.1	(pdk222_r061
		4) PT28HPCPDK_r1.0.1	(pdk222_r101)
		5) PT28HPCPDK_r1.0HF4	(pdk222_r10HF4)
		6) PT28HPCPDK_r1.0hf7	(pdk222_r10HF7)
	  q) quit..
	INPUT: Select ? 1
	========================================================
	INFO: Install kit 'dataSheets/T28HPC/0p5/FDK/./ADF/adf222_r061/PT28HPCADF_r0.6.1.dts' ..
	[1]: Reading dataSheets/T28HPC/0p5/FDK/./ADF/adf222_r061/PT28HPCADF_r0.6.1.dts
	ERROR: required kit dir 'T28HPC/0p5/FDK/PDK/pdk222_r061' has not been installed yet.
	ERROR: Skip install 'PT28HPCADF_r0.6.1' (dependency fail)

	------------------------------------------------------------------
	SUMMARY: Total 1/1 kits require check fail. (error)
	------------------------------------------------------------------
	==============================================================
	INFO: Please select the following packages to be installed :
	[ dataSheets/T28HPC/0p5/FDK ]:
	  0) Go back to previous selection menu..
		1) PT28HPCADF_r0.6.1
		2) PT28HPCCTK_r0.6.1
		3) PT28HPCPDK_r0.6.1
		4) PT28HPCPDK_r1.0.1
		5) PT28HPCPDK_r1.0HF4
		6) PT28HPCPDK_r1.0hf7
	  q) quit..
	INPUT: Select ? 3 2 1
	========================================================
	INFO: Install kit 'dataSheets/T28HPC/0p5/FDK/./PDK/pdk222_r061/PT28HPCPDK_r0.6.1.dts' ..
	[1]: Reading dataSheets/T28HPC/0p5/FDK/./PDK/pdk222_r061/PT28HPCPDK_r0.6.1.dts
	    : Package file - packages/PT28HPCPDK_r0.6.1.tgz
	INFO: Unpacking file 'packages/PT28HPCPDK_r0.6.1.tgz' ...
	pdk222_r061/
	pdk222_r061/README

	------------------------------------------------------------------
	SUMMARY: Total 1/1 kits are installed.
	------------------------------------------------------------------
	INFO: Install kit 'dataSheets/T28HPC/0p5/FDK/./CTK/ctk222_r061/PT28HPCCTK_r0.6.1.dts' ..
	[1]: Reading dataSheets/T28HPC/0p5/FDK/./CTK/ctk222_r061/PT28HPCCTK_r0.6.1.dts
	    : Package file - packages/PT28HPCCTK_r0.6.1.tgz
	INFO: Unpacking file 'packages/PT28HPCCTK_r0.6.1.tgz' ...
	ctk222_r061/
	ctk222_r061/README

	------------------------------------------------------------------
	SUMMARY: Total 1/1 kits are installed.
	------------------------------------------------------------------
	INFO: Install kit 'dataSheets/T28HPC/0p5/FDK/./ADF/adf222_r061/PT28HPCADF_r0.6.1.dts' ..
	[1]: Reading dataSheets/T28HPC/0p5/FDK/./ADF/adf222_r061/PT28HPCADF_r0.6.1.dts
	    : Package file - packages/PT28HPCADF_r0.6.1.tgz
	INFO: Unpacking file 'packages/PT28HPCADF_r0.6.1.tgz' ...
	adf222_r061/
	adf222_r061/README

	------------------------------------------------------------------
	SUMMARY: Total 1/1 kits are installed.
	------------------------------------------------------------------
	techLib
	└── T28HPC
	    └── 0p5
		└── FDK
		    ├── ADF
		    │   └── adf222_r061
		    ├── CTK
		    │   └── ctk222_r061
		    └── PDK
			└── pdk222_r061

	9 directories, 0 files
	==============================================================
	.....

	==============================================================
	INFO: Please select the following packages to be installed :
	[ dataSheets/ ]:
	  0) Go back to previous selection menu..
		1) PT28HPCADF_r0.6.1
		2) PT28HPCCTK_r0.6.1
		3) PT28HPCPDK_r0.6.1
		4) PT28HPCPDK_r1.0.1
		5) PT28HPCPDK_r1.0HF4
		6) PT28HPCPDK_r1.0hf7
		7) MEMORY_lib222_2PRF_e.0.6
		8) STDCELL_lib222_6t_base_e.1.0
		9) STDCELL_lib222_7t_base_e.2.0
		10) GPIO_lib222_e.0.6.1
	  q) quit..
	INPUT: Select ? 7 8 9 10
	.....
	==============================================================
	INFO: Please select the following packages to be installed :
	[ dataSheets/ ]:
	  0) Go back to previous selection menu..
		.....
	  q) quit..
	INPUT: Select ? q
	========================================================
	techLib
	└── T28HPC
	    └── 0p5
		├── FDK
		│   ├── ADF
		│   │   └── adf222_r061
		│   ├── CTK
		│   │   └── ctk222_r061
		│   └── PDK
		│       └── pdk222_r061
		├── FIP
		│   ├── MEMORY
		│   │   └── mem222_2prf_r061
		│   └── STDCELL
		│       └── lib222_6t_base_e10
		└── HIP
		    └── GPIO
			└── ip222_gpio_r061

	17 directories, 0 files
	TIME: @20171109_024710 END   tlp_install
	========================================================

	% cat techLib/.tlp_install.log

	20171109024620 toolsadm % tlp_install dataSheets/T28HPC/0p5/FDK/./PDK/pdk222_r061/PT28HPCPDK_r0.6.1.dts
	20171109024622 toolsadm % tlp_install dataSheets/T28HPC/0p5/FDK/./CTK/ctk222_r061/PT28HPCCTK_r0.6.1.dts
	20171109024623 toolsadm % tlp_install dataSheets/T28HPC/0p5/FDK/./ADF/adf222_r061/PT28HPCADF_r0.6.1.dts
	20171109024653 toolsadm % tlp_install dataSheets/T28HPC/0p5/FIP/STDCELL/lib222_6t_base_e10/STDCELL_lib222_6t_base_e.1.0.dts
	20171109024703 toolsadm % tlp_install dataSheets/T28HPC/0p5/FIP/MEMORY/mem222_2prf_r061/MEMORY_lib222_2PRF_e.0.6.dts
	20171109024706 toolsadm % tlp_install dataSheets/T28HPC/0p5/HIP/GPIO/ip222_gpio_r061/GPIO_lib222_e.0.6.1.dts

***
Step 3 - Create bundleLib from the bundle List:

	% make bundle

	  # cp techLib/T28HPC/0p5/.tlp_packages bundleFile.txt

	PT28HPCPDK_r0.6.1
	PT28HPCCTK_r0.6.1
	PT28HPCADF_r0.6.1
	STDCELL_lib222_6t_base_e.1.0
	MEMORY_lib222_2PRF_e.0.6
	GPIO_lib222_e.0.6.1

	  # tlp_install --targetLibDir bundleLib --bundleList bundleFile.txt

	% tree -d bundleLib

	bundleLib/
	└── T28HPC
	    └── 0p5
		├── FDK
		│   ├── ADF
		│   │   └── adf222_r061
		│   ├── CTK
		│   │   └── ctk222_r061
		│   └── PDK
		│       └── pdk222_r061
		├── FIP
		│   ├── MEMORY
		│   │   └── mem222_2prf_r061
		│   └── STDCELL
		│       └── lib222_6t_base_e10
		└── HIP
		    └── GPIO
			└── ip222_gpio_r061

	17 directories
