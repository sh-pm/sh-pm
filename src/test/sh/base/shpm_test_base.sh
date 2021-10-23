# ======================================
# "Set-Up"
# ======================================
set_up(){
	ACTUAL_ROOT_DIR_PATH="$ROOT_DIR_PATH"
	ACTUAL_LIB_DIR_PATH="$LIB_DIR_PATH"
	ACTUAL_SRC_DIR_PATH="$SRC_DIR_PATH"
	ACTUAL_TARGET_DIR_PATH="$TARGET_DIR_PATH"
	ACTUAL_SRC_RESOURCES_DIR_PATH="$SRC_RESOURCES_DIR_PATH"
	ACTUAL_TEST_RESOURCES_DIR_PATH="$TEST_RESOURCES_DIR_PATH"
}

# ======================================
# "Teardown"
# ======================================

tear_down() {
	trap "" EXIT
	#remove_file_and_folders_4tests 
	restore_initial_env_after_tests 
}

restore_initial_env_after_tests() {
	ROOT_DIR_PATH="$ACTUAL_ROOT_DIR_PATH"
	LIB_DIR_PATH="$ACTUAL_LIB_DIR_PATH"
	SRC_DIR_PATH="$ACTUAL_SRC_DIR_PATH"
	TARGET_DIR_PATH="$ACTUAL_TARGET_DIR_PATH"
	
	source "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME"
}

remove_file_and_folders_4tests() {
	local ACTUAL_DIR
	ACTUAL_DIR=$(pwd -P)
	
	cd "$TMP_DIR_PATH" || exit 1

	echo "   Removing $FOLDERNAME_4TEST"	
	rm -rf "$FOLDERNAME_4TEST"
	
	echo "   Removing $FILENAME_4TEST"
	rm -f "$FILENAME_4TEST"
	
	echo "   Removing $PROJECTNAME_4TEST"
	rm -rf "$PROJECTNAME_4TEST"
	
	if [[ -d "$ACTUAL_DIR" ]]; then
		cd "$ACTUAL_DIR" || exit 1
	fi
}

# ======================================
# Util Function's to run BEFORE Test exec
# ======================================
change_execution_to_project-only-4tests() {
	change_execution_to_project "project-only-4tests"
}

change_execution_to_project() {
	local PROJECTNAME="$1"

	# -- DO Override shpm bootstrap load with sh-project-only-4tests bootstrap load -- 
	ROOT_DIR_PATH="$TMP_DIR_PATH/$PROJECTNAME"
	LIB_DIR_PATH="$ROOT_DIR_PATH/$LIB_DIR_SUBPATH"
	SRC_DIR_PATH="$ROOT_DIR_PATH/$SRC_DIR_SUBPATH"
	TARGET_DIR_PATH="$ROOT_DIR_PATH/$TARGET_DIR_SUBPATH"
	SRC_RESOURCES_DIR_PATH="$ROOT_DIR_PATH/$SRC_RESOURCES_DIR_SUBPATH"
	TEST_RESOURCES_DIR_PATH="$ROOT_DIR_PATH/$TEST_RESOURCES_DIR_SUBPATH"
	
	source "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" || echo "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME not exists" 
	# -- -----------------------------------------------------------------------------
}

# ======================================
# Util Function's to run AFTER Test exec
# ======================================
undo_change_execution_to_project() {
	# -- UNDO Override shpm bootstrap load with sh-project-only-4tests bootstrap load --
	ROOT_DIR_PATH="$ACTUAL_ROOT_DIR_PATH"
	LIB_DIR_PATH="$ACTUAL_LIB_DIR_PATH"
	SRC_DIR_PATH="$ACTUAL_SRC_DIR_PATH"
	TARGET_DIR_PATH="$ACTUAL_TARGET_DIR_PATH"
	SRC_RESOURCES_DIR_PATH="$ACTUAL_SRC_RESOURCES_DIR_SUBPATH"
	TEST_RESOURCES_DIR_PATH="$ACTUAL_TEST_RESOURCES_DIR_SUBPATH"
	
	source "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME"
	#-----------------------------------------------------------------------------------
}