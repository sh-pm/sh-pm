#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit

# ======================================
# SUT
# ======================================
include_file "$LIB_DIR_PATH/sh-unit-v1.5.5/asserts.sh"

# ======================================
# Teardown
# ======================================
trap "remove_file_and_folder_4tests" EXIT
remove_file_and_folder_4tests() {
	local ACTUAL_DIR
	ACTUAL_DIR=$(pwd)

    echo "Remove $FOLDERNAME_4TEST and $FILENAME_4TEST in $TMP_DIR_PATH before test finish ..."
	
	cd "$TMP_DIR_PATH" || exit 1
	
	rm -rf "$FOLDERNAME_4TEST"
	rm -f "$FILENAME_4TEST"
	
	echo "Removed!"
	
	cd "$ACTUAL_DIR" || exit 1
}

# ======================================
# Tests
# ======================================
test_evict_catastrophic_remove_when_ROOT_DIR_PATH_is_set() {	
	source ../../../bootstrap.sh
	evict_catastrophic_remove > /dev/null 2>&1
	assert_true $?
}

test_evict_catastrophic_remove_when_ROOT_DIR_PATH_is_unset() {		
	unset ROOT_DIR_PATH
	evict_catastrophic_remove > /dev/null 2>&1
	assert_false $?
}

test_create_path_if_not_exists(){
	remove_file_and_folder_4tests
	
	local PATH_TARGET
	PATH_TARGET="$TMP_DIR_PATH/$FOLDERNAME_4TEST/subfolder1/subfolder1_1"
	
	if [[ ! -z "$PATH_TARGET" ]]; then
		remove_file_and_folder_4tests
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
	
	remove_file_and_folder_4tests
}

test_remove_folder_if_exists() {
	remove_file_and_folder_4tests
	
	local PATH_TARGET
	
	remove_folder_if_exists "$PATH_TARGET"
	assert_false "$?" || assert_fail "try remove not existing folder: not set variable"
	
	PATH_TARGET=""
	remove_folder_if_exists "$PATH_TARGET"
	assert_false "$?" || assert_fail "try remove not existing folder: empty variable"
	 
	PATH_TARGET="$TMP_DIR_PATH/$FOLDERNAME_4TEST/subfolder1/subfolder1_1"
	if [[ -d "$PATH_TARGET" ]]; then
		assert_fail "fail expected not existing path but path alread exists"
	fi 
	remove_folder_if_exists "$PATH_TARGET"	
	assert_false "$?" || assert_fail "try remove not existing path"	
	
	PATH_TARGET="$TMP_DIR_PATH/$FOLDERNAME_4TEST/subfolder1/subfolder1_1"
	mkdir -p "$PATH_TARGET" 
	remove_folder_if_exists "$PATH_TARGET"
	assert_true "$?" || assert_fail "fail removing existing complete path"
	
	remove_file_and_folder_4tests
}

test_remove_tar_gz_from_folder() {
	remove_file_and_folder_4tests
	
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
	
	remove_file_and_folder_4tests
}

test_remove_file_if_exists() {
	remove_file_and_folder_4tests

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
	
	remove_file_and_folder_4tests
}

run_all_tests_in_this_script