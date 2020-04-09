# Design Collateral Management Format

## TLP Syntax -

TLP	– TLP config file definition :

	FORMAT		1.0				; current format is TLP v1.0 
	AUTHOR		<email>
	DATE		YYYY_MMDD 
	…
	END						; end of TLP configuration section 

KIT	-  design kit information :

	NODE		<process_node>			; process node name
		Ex. : T7FFC | T16FFC | T28HPC 

	PDK 		<process_pdk>			; pdk release version
		Ex. :  x1r1 | x1r2 | x1r3 | x2r0 | x2r1 | x2r2 | x2r3

	GROUP		<kit_group>			; ICF functional group
		Ex. : FDK | FIP | HIP

	TYPE  		<kit_type>			; design kit type
		Ex. : PDK | CTK | ADF | STDCELL | MEMORY | GPIO | DDR | SERDES

	VERSION		<kit_version>
		- Follow the naming convention defined by each collateral type

	ORIGIN		<kit_origin>
		- Specify the original parent version which this kit is developed from

	TOPDIR		<kit_topdir>			
		- Specify the top directory name in the collateral package 

	SIZE		<kit_size>
		- Specify the disk size of the kit package  

	MD5SUM		<kit_md5sum> 
		- MD5 checksum of the target directory to ensure that installation process is successful 

REQUIRE – pre-install dependency rule :

	KIT	<req_kit_type> TOPDIR <req_kit_topdir>
		Kit dependency check - based on kit directory name

	KIT	<req_kit_type> VERSION <req_kit_version1>
		Kit dependency check - based on kit version

PACKAGE - package installation procedure :

	BASE	<base_kit_tlp>		[ <installed_kit_dir> ]
		- If the collateral kit is a hot fix with partial patch, tool will need to install its base kit first

	FILE	<package_file>		[ MD5SUM	<md5sum> ]
		- If the collateral kit contains multiple package files, tool will install them one by one
		- MD5SUM checksum is optional, it is used to validate each package before starting installation

	TARGET	<target_directory>	
		Specify the final kit directory name. “-”  means to use kit’s default top directory name


## Example :

	::::::::::::::
	PT28HPCPDK_r0.6.1.tlp
	::::::::::::::
	TLP	FORMAT	1.0			; header for TLP releaseNote

	KIT   	NODE	T28HPC
	KIT	PDK	0p5
	KIT	GROUP	FDK			; base on ICF functional group 
	KIT	TYPE	PDK			; kit type value is pre-defined 
	KIT	VERSION	r0.6.1			; follow the naming convention of each kit
	KIT	ORIGIN	- 			; current version is the initial release
	KIT	TOPDIR	pdk222_r061
	KIT	SIZE	10000
	KIT	MD5SUM 	fa6136891da5ce964961abc1f78aaa3c
 	
	PACKAGE	FILE	PT28HPCPDK_r0.6.1.tgz
	
	END 	; below this line, all content are ignore by tool
	
	::::::::::::::
	PT28HPCPDK_r1.0hf7.tlp
	::::::::::::::
	TLP	FORMAT	1.0
	
	KIT	NODE	T28HPC
	KIT	PDK	0p5
	KIT	GROUP	FDK
	KIT	TYPE	PDK
	KIT	VERSION	r1.0hf7
	KIT	ORIGIN	r1.0HF6  	;this version is patched based on r1.0HF6
	KIT	TOPDIR	pdk222_r10HF7
	KIT	SIZE	10000
	KIT	MD5SUM 	11ba9bfa12c16459bc242c005c351b6f
	
	REQUIRE	KIT	T28HPC/0p5/FDK/PDK	TOPDIR	pdk222_r101
	REQUIRE KIT	T28HPC/0p5/FDK/PDK	TOPDIR	pdk222_r10HF4
	
	; Need to install base package first if this is a partial hot fix
	PACKAGE BASE	PT28HPCPDK_r1.0HF4	T28HPC/0p5/FDK/PDK/pdk222_r10HF4
	PACKAGE FILE	PT28HPCPDK_r1.0hf5.tgz
	PACKAGE FILE	PT28HPCPDK_r1.0hf6.tgz
	PACKAGE FILE	PT28HPCPDK_r1.0hf7.tgz
	
	END

