run_clean_release() {
	clean_release
}

clean_release() {
	local PROJECT_DIR
	local RELEASES_DIR
	
	PROJECT_DIR="$1"
	
	RELEASES_DIR="$PROJECT_DIR/releases"
	TARGET_DIR="$PROJECT_DIR/$TARGET_DIR_SUBPATH"

	shpm_log_operation "Cleaning release"
	
	remove_tar_gz_from_folder "$RELEASES_DIR"
		
	remove_folder_if_exists "$TARGET_DIR"
	
	create_path_if_not_exists "$TARGET_DIR"
}


run_release_package() {

    clean_release "$ROOT_DIR_PATH"

	run_shellcheck 
	
	run_all_tests
	
	# Verify if are unit test failures
	if [ ! -z "${TEST_STATUS+x}" ]; then
		if [[ "$TEST_STATUS" != "OK" ]]; then
			shpm_log "Unit Test's failed!"
			exit 1; 
		fi
	fi

	shpm_log_operation "Build Release"

	shpm_log "Remove $TARGET_DIR_PATH folder ..."
	remove_folder_if_exists "$TARGET_DIR_PATH"
	
	TARGET_FOLDER="$ARTIFACT_ID""-""$VERSION"
	
	create_path_if_not_exists "$TARGET_DIR_PATH/$TARGET_FOLDER"

	shpm_log "Coping .sh files from $SRC_DIR_PATH/* to $TARGET_DIR_PATH/$TARGET_FOLDER ..."
	cp -R "$SRC_DIR_PATH"/* "$TARGET_DIR_PATH/$TARGET_FOLDER"
	
	# if not build itself
	if [[ ! -f "$SRC_DIR_PATH/shpm.sh" ]]; then
		shpm_log "Coping $DEPENDENCIES_FILENAME ..."
		cp "$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME" "$TARGET_DIR_PATH/$TARGET_FOLDER"
	else 
		shpm_log "Creating $DEPENDENCIES_FILENAME ..."
	    cp "$SRC_DIR_PATH/../resources/template_$DEPENDENCIES_FILENAME" "$TARGET_DIR_PATH/$TARGET_FOLDER/$DEPENDENCIES_FILENAME"
	    
	    shpm_log "Coping $BOOTSTRAP_FILENAME from $ROOT_DIR_PATH ..."
    	cp "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" "$TARGET_DIR_PATH/$TARGET_FOLDER"
	fi
	
	shpm_log "Add sh-pm comments in .sh files ..."
	cd "$TARGET_DIR_PATH/$TARGET_FOLDER" || exit
	sed -i 's/\#\!\/bin\/bash/\#\!\/bin\/bash\n# '"$VERSION"' - Build with sh-pm/g' ./*.sh
		
	# if not build itself
	if [[ ! -f $TARGET_DIR_PATH/$TARGET_FOLDER/"shpm.sh" ]]; then
		shpm_log "Removing $BOOTSTRAP_FILENAME sourcing command from .sh files ..."
		sed -i "s/source \.\/$BOOTSTRAP_FILENAME//g" ./*.sh		
		sed -i "s/source \.\.\/\.\.\/\.\.\/$BOOTSTRAP_FILENAME//g" ./*.sh
	else
		shpm_log "Update $BOOTSTRAP_FILENAME sourcing command from .sh files ..."
	   	sed -i "s/source \.\.\/\.\.\/\.\.\/$BOOTSTRAP_FILENAME/source \.\/$BOOTSTRAP_FILENAME/g" shpm.sh	   	
	fi
	
	shpm_log "Package: Compacting .sh files ..."
	cd "$TARGET_DIR_PATH" || exit
	tar -czf "$TARGET_FOLDER"".tar.gz" "$TARGET_FOLDER"
	
	if [[ -d "$TARGET_DIR_PATH/$TARGET_FOLDER" ]]; then
		rm -rf "${TARGET_DIR_PATH:?}/${TARGET_FOLDER:?}"
	fi
	
	shpm_log "Relese file generated in folder $TARGET_DIR_PATH"
	
	cd "$ROOT_DIR_PATH" || exit
	
	shpm_log "Done"
}

run_publish_release() {
	local GIT_PROJECT
	local VERBOSE=$1
	
	GIT_PROJECT="$( basename "$ROOT_DIR_PATH" )"

	clean_release "$ROOT_DIR_PATH"
	
	build_release

	shpm_log_operation "Starting publish release process"
	
	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local TGZ_FILE_NAME=$TARGET_FOLDER".tar.gz"
	local FILE_PATH=$TARGET_DIR_PATH/$TGZ_FILE_NAME
	
	shpm_log_operation "Copying .tgz file to releaes folder"
	local RELEASES_PATH

	RELEASES_PATH="$ROOT_DIR_PATH""/""releases"

	if [[ ! -d "$RELEASES_PATH" ]]; then
		mkdir -p "$RELEASES_PATH"
	fi

	cp "$FILE_PATH" "$RELEASES_PATH" 
	
	local GIT_REMOTE_USERNAME
	local GIT_REMOTE_PASSWORD
	
	echo "---> $GIT_PROJECT"
	
	read_git_username_and_password
	
	create_new_remote_branch_from_master_branch "github.com" "$GIT_PROJECT" "$GIT_REMOTE_USERNAME" "$GIT_REMOTE_PASSWORD" "$VERSION"
}
