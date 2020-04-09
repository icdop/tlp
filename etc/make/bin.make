BIN_PATH := bin
CSH_PATH := ../csh

bin: csh/* csh/
	mkdir -p $(BIN_PATH)
	rm -fr $(BIN_PATH)/tlp_*
	ln -f -s $(CSH_PATH)/tlp_help.csh			$(BIN_PATH)/tlp_help
	ln -f -s $(CSH_PATH)/tlp_pack.csh			$(BIN_PATH)/tlp_pack
	ln -f -s $(CSH_PATH)/tlp_import.csh			$(BIN_PATH)/tlp_import
	ln -f -s $(CSH_PATH)/tlp_install.csh			$(BIN_PATH)/tlp_install
	ln -f -s $(CSH_PATH)/tlp_check.csh			$(BIN_PATH)/tlp_check
