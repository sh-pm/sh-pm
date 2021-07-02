create_path_if_not_exists() {
	local PATH_TARGET
	PATH_TARGET="$1"
	
	if [[ -z "$PATH_TARGET" ]]; then
		shpm_log "${FUNCNAME[0]} run with empty param: |$PATH_TARGET|"
		return 1
	fi 

	if [[ ! -d "$PATH_TARGET" ]]; then
	   shpm_log "- Creating $PATH_TARGET ..."
	   mkdir -p "$PATH_TARGET"
	fi
}

remove_folder_if_exists() {
	local PATH_TO_FOLDER
	local ACTUAL_DIR
	
	ACTUAL_DIR=$(pwd)
	PATH_TO_FOLDER="$1"
	
	if [[ -z "$PATH_TO_FOLDER" ]]; then
		shpm_log "${FUNCNAME[0]} run with empty param: |$PATH_TO_FOLDER|"
		return "$FALSE"
	fi 
	
	if [[ -d "$PATH_TO_FOLDER" ]]; then
		shpm_log "- Exec secure remove of folder $PATH_TO_FOLDER ..."
	
		##
		 # SECURE rm -rf: move content to TMP_DIR, and execute rm -rf only inside TMP_DIR
		 ##
		# If a folder not already in tmp dir 
		if [[ "$TMP_DIR_PATH/"$( basename "$PATH_TO_FOLDER") != "$PATH_TO_FOLDER" ]]; then
			mv "$PATH_TO_FOLDER" "$TMP_DIR_PATH"
		fi
		
		cd "$TMP_DIR_PATH" || exit
		
		rm -rf "$(basename "$PATH_TO_FOLDER")"
		
		cd "$ACTUAL_DIR" || exit
		
		return "$TRUE"
	else
	    return "$FALSE"	
	fi
}

remove_file_if_exists() {
	local PATH_TO_FILE
	local ACTUAL_DIR
	
	ACTUAL_DIR=$(pwd)
	PATH_TO_FILE="$1"
	
	if [[ -z "$PATH_TO_FILE" ]]; then
		shpm_log "${FUNCNAME[0]} run with empty param: |$PATH_TO_FILE|"
		return 1
	fi 
	
	if [[ -f "$PATH_TO_FILE" ]]; then
		shpm_log "- Exec secure remove of file $PATH_TO_FILE ..."
	
		# SECURE rm -rf: move content to TMP_DIR, and execute rm -rf only inside TMP_DIR
		if [[ "$PATH_TO_FILE" != "$TMP_DIR_PATH"/$(basename "$PATH_TO_FILE") ]]; then
			mv "$PATH_TO_FILE" "$TMP_DIR_PATH"
		fi
		
		cd "$TMP_DIR_PATH" || exit
		
		rm -f "$(basename "$PATH_TO_FILE")"
		
		cd "$ACTUAL_DIR" || exit
			
		return "$TRUE"
	else
	    return "$FALSE"	
	fi
}

remove_tar_gz_from_folder() {
	local ACTUAL_DIR
	local FOLDER
	
	ACTUAL_DIR=$(pwd)
	FOLDER="$1"
	
	if [[ ! -z "$FOLDER" && -d "$FOLDER" ]]; then
	
		shpm_log "Removing *.tar.gz files from $FOLDER ..."
		
		cd "$FOLDER" || exit 1
		rm ./*.tar.gz 2> /dev/null
		
		shpm_log "Done"		
	else
		shpm_log "ERROR: $FOLDER not found."
		return "$FALSE" 
	fi
	
	cd "$ACTUAL_DIR" || exit
	
	return "$TRUE"
}
