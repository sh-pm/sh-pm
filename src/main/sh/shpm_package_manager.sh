run_update_dependencies() {
	shpm_log_operation "Update Dependencies"
	
    local VERBOSE="$1"
	
	shpm_log "Start update of ${#DEPENDENCIES[@]} dependencies ..."
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
		update_dependency "$DEP_ARTIFACT_ID" "$VERBOSE"
	done
	
	cd "$ROOT_DIR_PATH" || exit 1
	
	shpm_log "Done"
}

shpm_update_itself_after_git_clone() {
    shpm_log "WARN: sh-pm updating itself ..." "yellow"
    
    local PATH_TO_DEP_IN_TMP
    local PATH_TO_DEP_IN_PROJECT
    
    PATH_TO_DEP_IN_TMP="$1"
    PATH_TO_DEP_IN_PROJECT="$2"
    
    shpm_log "     - Copy $BOOTSTRAP_FILENAME to $PATH_TO_DEP_IN_PROJECT ..."
	cp "$PATH_TO_DEP_IN_TMP/$BOOTSTRAP_FILENAME" "$PATH_TO_DEP_IN_PROJECT"
			
	shpm_log "     - Update $BOOTSTRAP_FILENAME sourcing command from shpm.sh file ..."
	sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh/source \.\/bootstrap.sh/g' "$PATH_TO_DEP_IN_PROJECT/shpm.sh"
    
    if [[ -f "$ROOT_DIR_PATH/shpm.sh" ]]; then
    	create_path_if_not_exists "$ROOT_DIR_PATH/tmpoldshpm"
    	
    	shpm_log "   - backup actual sh-pm version to $ROOT_DIR_PATH/tmpoldshpm ..."
    	mv "$ROOT_DIR_PATH/shpm.sh" "$ROOT_DIR_PATH/tmpoldshpm"
    fi
    
    if [[ -f "$PATH_TO_DEP_IN_PROJECT/shpm.sh" ]]; then
    	shpm_log "   - update shpm.sh ..."
    	cp "$PATH_TO_DEP_IN_PROJECT/shpm.sh"	"$ROOT_DIR_PATH"
    fi
    
    if [[ -f "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" ]]; then
    	shpm_log "   - backup actual $BOOTSTRAP_FILENAME to $ROOT_DIR_PATH/tmpoldshpm ..."
    	mv "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" "$ROOT_DIR_PATH/tmpoldshpm"
    fi
    
    if [[ -f "$PATH_TO_DEP_IN_PROJECT/$BOOTSTRAP_FILENAME" ]]; then
    	shpm_log "   - update $BOOTSTRAP_FILENAME ..."
    	cp "$PATH_TO_DEP_IN_PROJECT/$BOOTSTRAP_FILENAME"	"$ROOT_DIR_PATH"
    fi
}

set_dependency_repository(){
	local DEP_ARTIFACT_ID
	local R2_DEP_REPOSITORY # (R)eference (2)nd: will be attributed to 2nd param by reference	
	local ARTIFACT_DATA
	
	DEP_ARTIFACT_ID="$1"
	ARTIFACT_DATA="${DEPENDENCIES[$DEP_ARTIFACT_ID]}"
	
	if [[ "$ARTIFACT_DATA" == *"@"* ]]; then
		R2_DEP_REPOSITORY=$( echo "$ARTIFACT_DATA" | cut -d "@" -f 2 | xargs ) #xargs is to trim string!
		
		if [[ "$R2_DEP_REPOSITORY" == "" ]]; then
			shpm_log "Error in $DEP_ARTIFACT_ID dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
			exit 1
		fi
	else
		shpm_log "Error in $DEP_ARTIFACT_ID dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
		exit 1
	fi
	
	eval "$2=$R2_DEP_REPOSITORY"
}

set_dependency_version(){
	local DEP_ARTIFACT_ID
	local R2_DEP_VERSION	# (R)eference (2)nd: will be attributed to 2nd param by reference
	
	DEP_ARTIFACT_ID="$1"
	
	local ARTIFACT_DATA="${DEPENDENCIES[$DEP_ARTIFACT_ID]}"
	if [[ "$ARTIFACT_DATA" == *"@"* ]]; then
		R2_DEP_VERSION=$( echo "$ARTIFACT_DATA" | cut -d "@" -f 1 | xargs ) #xargs is to trim string!						
	else
		shpm_log "Error in $DEP_ARTIFACT_ID dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
		exit 1
	fi
	
	eval "$2=$R2_DEP_VERSION"
}

update_dependency() {
    local DEP_ARTIFACT_ID=$1
    local VERBOSE=$2
    
	local DEP_VERSION
	local REPOSITORY
	local DEP_FOLDER_NAME
	local PATH_TO_DEP_IN_PROJECT
	local PATH_TO_DEP_IN_TMP
	
	local ACTUAL_DIR
	
	ACTUAL_DIR=$( pwd )
	
	create_path_if_not_exists "$LIB_DIR_PATH" 
	
	set_dependency_repository "$DEP_ARTIFACT_ID" REPOSITORY 
	set_dependency_version "$DEP_ARTIFACT_ID" DEP_VERSION

	DEP_FOLDER_NAME="$DEP_ARTIFACT_ID""-""$DEP_VERSION"
	PATH_TO_DEP_IN_PROJECT="$LIB_DIR_PATH/$DEP_FOLDER_NAME"
	PATH_TO_DEP_IN_TMP="$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	
	shpm_log "----------------------------------------------------"
	reset_g_indent 
	increase_g_indent 	
	shpm_log "Updating $DEP_ARTIFACT_ID to $DEP_VERSION: Start"				
	 
	increase_g_indent
	if download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"; then
	
		remove_folder_if_exists "$PATH_TO_DEP_IN_PROJECT"		
		create_path_if_not_exists "$PATH_TO_DEP_IN_PROJECT"
				
		shpm_log "- Copy artifacts from $PATH_TO_DEP_IN_TMP to $PATH_TO_DEP_IN_PROJECT ..."
		cp "$PATH_TO_DEP_IN_TMP/src/main/sh/"* "$PATH_TO_DEP_IN_PROJECT"
		cp "$PATH_TO_DEP_IN_TMP/pom.sh" "$PATH_TO_DEP_IN_PROJECT"
		
		# if update a sh-pm
		if [[ "$DEP_ARTIFACT_ID" == "sh-pm" ]]; then
			shpm_update_itself_after_git_clone "$PATH_TO_DEP_IN_TMP" "$PATH_TO_DEP_IN_PROJECT"
		fi
		
		shpm_log "- Removing $PATH_TO_DEP_IN_TMP ..."
		increase_g_indent
		remove_folder_if_exists "$PATH_TO_DEP_IN_TMP"
		decrease_g_indent
		
		cd "$ACTUAL_DIR" || exit
	
	else 		   		  
       shpm_log "$DEP_ARTIFACT_ID was not updated to $DEP_VERSION!"
	fi
	
	decrease_g_indent 	
	shpm_log "Update $DEP_ARTIFACT_ID to $DEP_VERSION: Finish"
	
	reset_g_indent 
	
	cd "$ACTUAL_DIR" || exit 1
}
