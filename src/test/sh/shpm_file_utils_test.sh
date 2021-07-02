#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/shpm_test_base.sh"

# ======================================
# SUT
# ======================================
include_file "$SRC_DIR_PATH/shpm_file_utils.sh"

# ======================================
# "Set-Up"
# ======================================
set_up

# ======================================
# "Teardown"
# ======================================
trap "tear_down" EXIT

# ======================================
# Tests
# ======================================

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
# Util Function's to run Before Test exec
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


test_create_path_if_not_exists(){
	remove_file_and_folders_4tests
	
	local PATH_TARGET
	PATH_TARGET="$TMP_DIR_PATH/$FOLDERNAME_4TEST/subfolder1/subfolder1_1"
	
	if [[ ! -z "$PATH_TARGET" ]]; then
		remove_file_and_folders_4tests
	fi
	
	if [[ -d "$PATH_TARGET" ]]; then
		assert_fail "fail remove folder before start test" 
	fi
	
	create_path_if_not_exists "$PATH_TARGET"
	assert_true "$?"
	if [[ ! -d "$PATH_TARGET" ]]; then
		assert_fail "fail creating not existing path"
	fi
	
	create_path_if_not_exists "$PATH_TARGET"
	assert_true "$?"
	if [[ ! -d "$PATH_TARGET" ]]; then
		assert_fail "fail try creating already existing path"
	fi
	
	remove_file_and_folders_4tests
}

test_remove_folder_if_exists() {
	remove_file_and_folders_4tests
	
	local PATH_TARGET
	
	remove_folder_if_exists "$PATH_TARGET"
	assert_false "$?" || assert_fail "try remove not existing folder: not set variable"
	
	PATH_TARGET=""
	remove_folder_if_exists "$PATH_TARGET"
	assert_false "$?" || assert_fail "try remove not existing folder: empty variable"
	 
	PATH_TARGET="$TMP_DIR_PATH/$FOLDERNAME_4TEST/subfolder1/subfolder1_1"
	if [[ -d "$PATH_TARGET" ]]; then
		assert_fail "fail expected not existing path but path already exists"
	fi 
	remove_folder_if_exists "$PATH_TARGET"	
	assert_false "$?" || assert_fail "try remove not existing path"	
	
	PATH_TARGET="$TMP_DIR_PATH/$FOLDERNAME_4TEST/subfolder1/subfolder1_1"
	mkdir -p "$PATH_TARGET" 
	remove_folder_if_exists "$PATH_TARGET"
	assert_true "$?" || assert_fail "fail removing existing complete path"
	
	remove_file_and_folders_4tests
}

test_remove_tar_gz_from_folder() {
	remove_file_and_folders_4tests
	
	local TARGET_FOLDER
	local TARGZ_FILE
	local TARGZ_PATH
	
	TARGET_FOLDER="$TMP_DIR_PATH/$FOLDERNAME_4TEST"
	TARGZ_FILE="$FILENAME_4TEST"".tar.gz"
	TARGZ_PATH="$TARGET_FOLDER/$TARGZ_FILE"
	
	mkdir -p "$TARGET_FOLDER"
	echo "test" > "$TARGZ_PATH"	
	if [[ ! -f "$TARGZ_PATH" ]]; then
		assert_fail "fail ensure exists folder with .tar.gz file inside"
	fi
	
	remove_tar_gz_from_folder "$TARGZ_PATH"
	assert_false "$?" || assert_fail "fail receiving file instead of folder"
	
	remove_tar_gz_from_folder "$TARGET_FOLDER"
	if [[ -f "$TARGZ_PATH" ]]; then
		assert_fail "fail remove .tar.gz file inside folder"
	fi
	
	remove_tar_gz_from_folder "$TARGET_FOLDER"
	assert_true "$?" || assert_fail "fail receivind folder without .tar.gz file inside folder"
	
	remove_file_and_folders_4tests
}

test_remove_file_if_exists() {
	remove_file_and_folders_4tests

	local PATH_TARGET
	
	remove_file_if_exists "$PATH_TARGET"
	assert_false "$?" || assert_fail "try remove not existing file: not set variable" 
	
	PATH_TARGET=""
	remove_file_if_exists "$PATH_TARGET"
	assert_false "$?" || assert_fail "try remove not existing file: empty variable"
	 
	PATH_TARGET="$TMP_DIR_PATH/$FOLDERNAME_4TEST/$FILENAME_4TEST"
	remove_file_if_exists "$PATH_TARGET"
	assert_false "$?" || assert_fail "try remove not existing path"
	
	# creating file
	PATH_TARGET="$TMP_DIR_PATH/$FOLDERNAME_4TEST/subfolder1/subfolder1_1"
	mkdir -p "$PATH_TARGET"
	PATH_TARGET="$PATH_TARGET/$FILENAME_4TEST"	
	echo "test" > "$PATH_TARGET" 
	 
	remove_file_if_exists "$PATH_TARGET"
	assert_true "$?" || assert_fail "fail removing existing complete path"
	
	remove_file_and_folders_4tests
}