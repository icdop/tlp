# TechLib Packakge Format

## TLP DEFINITION FILE Syntax -

HEADER	– TLP header section :

	BEGIN		TLP	<package_name>
	TYPE		<package_type>
		Ex. : FULL | PATCH

INFORMATION – information section :

	NODE		<process_node>			; process node name
		Ex. : T7FFC | T16FFC | T28HPC 

	MVER 		<model_version>			; pdk model release version
		Ex. :  0p1 | 0p5 | 0p9

	CATG		<kit_group>			; techlib group
		Ex. : FDK | FIP | HIP

	TYPE  		<kit_type>			; design kit type
		Ex. : PDK | CTK | ADF | STDCELL | MEMORY | GPIO | DDR | SERDES

	SDIR		<kit_source_dir>			
		- Specify the root directory name in the library package 

	SIZE		<kit_package_size>
		- Specify the disk size of the kit package  

	MD5S		<kit_md5sum> 
		- MD5 checksum of the target directory to ensure that installation process is successful 

DEPENDENCY – pre-install dependency check :

	REQU	KIT=<req_kit_name>
		Kit dependency check - based on kit name

	REQU	DIR=<req_kit_root>
		Kit dependency check - based on kit directory

PACKAGE - package installation procedure :

	BASE	<base_tlp_kit>		[ <target_kit_dir> ]
		- If the designkit kit is a hot fix with partial patch, tool will need to install its base kit first

	FILE	<package_file>		[ MD5SUM	<md5sum> ]
		- If the designkit kit contains multiple package files, tool will install them one by one
		- MD5SUM checksum is optional, it is used to validate each package before starting installation

	TDIR	<target_directory>	
		Specify the final kit directory name. “-”  means to use kit’s default directory name


## Example :

	::::::::::::::
	PT28HPCPDK_r0.6.1.tlp
	::::::::::::::
	BEGIN	TLP			; header for TLP dataSheet
	NAME	r0.6.1			; follow the naming convention of each kit
	ORIG	- 			; current version is the initial release

	NODE	T28HPC
	MVER	0p5
	CATG	FDK			; Foundry Design Kit
	TYPE	PDK			; kit type value is pre-defined 
	SDIR	pdk222_r061
	SIZE	10000
	MD5S 	fa6136891da5ce964961abc1f78aaa3c
 	
	FILE	PT28HPCPDK_r0.6.1.tgz
	
	END 	; below this line, all content are ignore by tool
	
	::::::::::::::
	PT28HPCPDK_r1.0hf7.tlp
	::::::::::::::
	BEGIN	TLP
	NAME	r1.0hf7
	ORIG	r1.0HF6  	;this version is patched based on r1.0HF6
	
	NODE	T28HPC
	MVER	0p5
	CATG	FDK
	TYPE	PDK
	SDIR	pdk222_r10HF7
	SIZE	10000
	MD5S 	11ba9bfa12c16459bc242c005c351b6f
	
	DEPT	T28HPC/0p5/FDK/PDK	SDIR=pdk222_r101
	DEPT	T28HPC/0p5/FDK/PDK	SDIR=pdk222_r10HF4
	
	; Need to install base package first if this is a partial hot fix
	REQU	PT28HPCPDK_r1.0HF4	T28HPC/0p5/FDK/PDK/pdk222_r10HF4
	FILE	PT28HPCPDK_r1.0hf5.tgz
	FILE	PT28HPCPDK_r1.0hf6.tgz
	FILE	PT28HPCPDK_r1.0hf7.tgz
	
	END

