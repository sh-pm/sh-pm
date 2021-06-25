#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit

# ======================================
# SUT
# ======================================
include_file "$LIB_DIR_PATH/sh-unit-v1.5.5/asserts.sh"

# ======================================
# SetUp
# ======================================
ACTUAL_ROOT_DIR_PATH="$ROOT_DIR_PATH"
ACTUAL_LIB_DIR_PATH="$LIB_DIR_PATH"
ACTUAL_SRC_DIR_PATH="$SRC_DIR_PATH"
ACTUAL_TARGET_DIR_PATH="$TARGET_DIR_PATH"


# ======================================
# Teardown
# ======================================
trap "clean_and_restore_env" EXIT


clean_and_restore_env() {
	remove_file_and_folders_4tests 
	restore_initial_env_before_tests 
}

restore_initial_env_before_tests() {
	ROOT_DIR_PATH="$ACTUAL_ROOT_DIR_PATH"
	LIB_DIR_PATH="$ACTUAL_LIB_DIR_PATH"
	SRC_DIR_PATH="$ACTUAL_SRC_DIR_PATH"
	TARGET_DIR_PATH="$ACTUAL_TARGET_DIR_PATH"
	
	source "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME"
}

remove_file_and_folders_4tests() {
	local ACTUAL_DIR
	ACTUAL_DIR=$(pwd)
	
	cd "$TMP_DIR_PATH" || exit 1

	echo "   Removing $FOLDERNAME_4TEST"	
	rm -rf "$FOLDERNAME_4TEST"
	
	echo "   Removing $FILENAME_4TEST"
	rm -f "$FILENAME_4TEST"
	
	echo "   Removing $PROJECTNAME_4TEST"
	rm -rf "$PROJECTNAME_4TEST"
	
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

test_shpm_log() {
	local STRING="teste 123 teste"
	
	SHPM_LOG_DISABLED="$FALSE"
	local STRING_LOGGED=$( shpm_log "$STRING" )
	SHPM_LOG_DISABLED="$TRUE"
	
	assert_equals "$STRING" "$STRING_LOGGED"
}

test_shpm_log_operation() {
	local EXPECTED
EXPECTED='================================================================
sh-pm: teste 123 teste
================================================================'

	SHPM_LOG_DISABLED="$FALSE"
	local STRING_LOGGED=$( shpm_log_operation "teste 123 teste" )
	SHPM_LOG_DISABLED="$TRUE"
	
	assert_equals "$EXPECTED" "$STRING_LOGGED"
}

test_clean_release() {
	local PROJECT_DIR
	local PROJECT_TARGET_DIR
	local PROJECT_RELEASES_DIR
	local RESULT
	
	download_from_git_to_tmp_folder "github.com/sh-pm" "sh-project-only-4tests" "v0.1.0"
	
	PROJECT_DIR="$TMP_DIR_PATH/sh-project-only-4tests"
	
	PROJECT_TARGET_DIR="$PROJECT_DIR/$TARGET_DIR_SUBPATH"	
	PROJECT_RELEASES_DIR="$PROJECT_DIR/releases"
	
	RESULT=$( find "$PROJECT_RELEASES_DIR" -name *.tar.gz )
	assert_false "$RESULT" "" || assert_fail "files *.tar.gz not found in $PROJECT_RELEASES_DIR"
	
	RESULT=$( find "$PROJECT_TARGET_DIR" -name *.tar.gz )
	assert_false "$RESULT" ""  || assert_fail "files *.tar.gz not found in $PROJECT_TARGET_DIR"
	
	clean_release "$PROJECT_DIR"
	
	RESULT=$( find "$PROJECT_RELEASES_DIR" -name *.tar.gz )
	assert_true "$RESULT" "" || assert_fail "before clean found files *.tar.gz in $PROJECT_RELEASES_DIR"
	
	
	RESULT=$( find "$PROJECT_TARGET_DIR" -name *.tar.gz )
	assert_true "$RESULT" "" || assert_fail "before clean found files *.tar.gz in $PROJECT_TARGET_DIR"

	remove_folder_if_exists "$PROJECT_DIR"
}

test_update_dependency() {

	local DEP_NAME
	local DEP_VERSION
	
	remove_folder_if_exists "$TMP_DIR_PATH/sh-project-only-4tests"
	
	download_from_git_to_tmp_folder "github.com/sh-pm" "sh-project-only-4tests" "v0.1.0"
	
	# -- DO Override shpm bootstrap load with sh-project-only-4tests bootstrap load -- 
	ROOT_DIR_PATH="$TMP_DIR_PATH/sh-project-only-4tests"
	LIB_DIR_PATH="$ROOT_DIR_PATH/$LIB_DIR_SUBPATH"
	SRC_DIR_PATH="$ROOT_DIR_PATH/$SRC_DIR_SUBPATH"
	TARGET_DIR_PATH="$ROOT_DIR_PATH/$TARGET_DIR_SUBPATH"	
	# -- -----------------------------------------------------------------------------
	
	DEP_NAME="sh-unit"
	DEP_VERSION="v1.5.5"
	DEP_OLD_VERSION="v1.5.3"
	
	FILENAME1_INSIDE_DEP="asserts.sh"
	FILENAME2_INSIDE_DEP="test_runner.sh"
	
	remove_folder_if_exists "$LIB_DIR_PATH" 
	
	update_dependency "sh-unit"
	
	if [[ ! -d "$LIB_DIR_PATH/$DEP_NAME-$DEP_VERSION" ]]; then
		assert_fail "Fail on download $DEP_NAME dependency"
	else
		assert_success
	fi
	
	mv "$LIB_DIR_PATH/$DEP_NAME-$DEP_VERSION" "$LIB_DIR_PATH/$DEP_NAME-$DEP_OLD_VERSION"
	if [[ ! -d "$LIB_DIR_PATH/$DEP_NAME-$DEP_OLD_VERSION" ]]; then
		assert_fail "Fail on rename sh-unit local dependency folder from $DEP_NAME-$DEP_VERSION to $DEP_NAME-$DEP_OLD_VERSION"
	else
		assert_success
	fi
	
	update_dependency "sh-unit"
	
	if [[ ! -d "$LIB_DIR_PATH/$DEP_NAME-$DEP_VERSION" ]]; then
		assert_fail "Fail on update $DEP_NAME dependency $DEP_VERSION"
	else 
		assert_success
	fi
	
	if [[ ! -f "$LIB_DIR_PATH/$DEP_NAME-$DEP_VERSION/$FILENAME1_INSIDE_DEP" ]]; then
		assert_fail "Fail on update $DEP_NAME dependency $DEP_VERSION: $FILENAME1_INSIDE_DEP not found"
	else
		assert_success
	fi
	
	if [[ ! -f "$LIB_DIR_PATH/$DEP_NAME-$DEP_VERSION/$FILENAME2_INSIDE_DEP" ]]; then
		assert_fail "Fail on update $DEP_NAME dependency $DEP_VERSION: $FILENAME2_INSIDE_DEP not found"
	else 
		assert_success
	fi
	
	remove_folder_if_exists "$ROOT_DIR_PATH"
	if [[ -d "$ROOT_DIR_PATH" ]]; then
		assert_fail "Fail on remove $ROOT_DIR_PATH"
	else
		assert_success
	fi
	
	# -- UNDO Override shpm bootstrap load with sh-project-only-4tests bootstrap load --
	ROOT_DIR_PATH="$ACTUAL_ROOT_DIR_PATH"
	LIB_DIR_PATH="$ACTUAL_LIB_DIR_PATH"
	SRC_DIR_PATH="$ACTUAL_SRC_DIR_PATH"
	TARGET_DIR_PATH="$ACTUAL_TARGET_DIR_PATH"
	#-----------------------------------------------------------------------------------
}

test_update_dependencies() {
	remove_folder_if_exists "$TMP_DIR_PATH/sh-project-only-4tests"
	
	download_from_git_to_tmp_folder "github.com/sh-pm" "sh-project-only-4tests" "v0.1.0"
	
	# -- DO Override shpm bootstrap load with sh-project-only-4tests bootstrap load -- 
	ROOT_DIR_PATH="$TMP_DIR_PATH/sh-project-only-4tests"
	LIB_DIR_PATH="$ROOT_DIR_PATH/$LIB_DIR_SUBPATH"
	SRC_DIR_PATH="$ROOT_DIR_PATH/$SRC_DIR_SUBPATH"
	TARGET_DIR_PATH="$ROOT_DIR_PATH/$TARGET_DIR_SUBPATH"
	source "$ROOT_DIR_PATH/pom.sh"	
	# -- -----------------------------------------------------------------------------
	
	assert_equals "${#DEPENDENCIES[@]}" "4" || assert_fail "Problem override content of original pom.sh"
	
	update_dependencies
	
	if [[ ! -d "$LIB_DIR_PATH/sh-pm-v4.1.0" ]]; then
		assert_fail "Fail on update $DEP_NAME dependency sh-pm-v4.1.0"
	else 
		assert_success
	fi
	
	if [[ ! -d "$LIB_DIR_PATH/sh-logger-v1.4.0" ]]; then
		assert_fail "Fail on update $DEP_NAME dependency sh-logger-v1.4.0"
	else 
		assert_success
	fi
	
	if [[ ! -d "$LIB_DIR_PATH/sh-commons-v2.2.3" ]]; then
		assert_fail "Fail on update $DEP_NAME dependency sh-commons-v2.2.3"
	else 
		assert_success
	fi
	
	if [[ ! -d "$LIB_DIR_PATH/sh-unit-v1.5.5" ]]; then
		assert_fail "Fail on update $DEP_NAME dependency sh-unit-v1.5.5"
	else 
		assert_success
	fi
	
	# -- UNDO Override shpm bootstrap load with sh-project-only-4tests bootstrap load --
	ROOT_DIR_PATH="$ACTUAL_ROOT_DIR_PATH"
	LIB_DIR_PATH="$ACTUAL_LIB_DIR_PATH"
	SRC_DIR_PATH="$ACTUAL_SRC_DIR_PATH"
	TARGET_DIR_PATH="$ACTUAL_TARGET_DIR_PATH"
	source "$ROOT_DIR_PATH/pom.sh"
	#-----------------------------------------------------------------------------------
	
	assert_equals "${#DEPENDENCIES[@]}" "2" || assert_fail "Problem restore/reload content of original pom.sh to undo override changes"
	
	#for key in ${!DEPENDENCIES[@]}; do
	#	echo "$key - ${DEPENDENCIES[$key]}"
	#done 
}

test_git_clone() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.1.0"

	local ACTUAL_DIR
	ACTUAL_DIR=$(pwd)
	
	cd "$TMP_DIR_PATH"
	
	remove_folder_if_exists "$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	if [[ -d "$TMP_DIR_PATH/$DEP_ARTIFACT_ID" ]]; then
		assert_fail "$TMP_DIR_PATH/$DEP_ARTIFACT_ID already exists"
	fi 

	git_clone "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"
	assert_equals "$?" "$TRUE"
	
	if [[ ! -d "$TMP_DIR_PATH/$DEP_ARTIFACT_ID" ]]; then
		assert_fail "fail git clone $DEP_ARTIFACT_ID to $TMP_DIR_PATH"
	else
		assert_success
	fi 
	
	remove_folder_if_exists "$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	if [[ -d "$TMP_DIR_PATH/$DEP_ARTIFACT_ID" ]]; then
		assert_fail "fail remove $TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	fi 
	
	cd "$ACTUAL_DIR"
}

test_increase_g_indent() {
	G_SHPMLOG_INDENT=""
	
	increase_g_indent
	assert_equals "$G_SHPMLOG_INDENT" "  "
	
	increase_g_indent
	assert_equals "$G_SHPMLOG_INDENT" "    "
	
	increase_g_indent
	assert_equals "$G_SHPMLOG_INDENT" "      "
	
	reset_g_indent
}

test_decrease_g_indent() {
	G_SHPMLOG_INDENT="      "
	
	decrease_g_indent
	assert_equals "$G_SHPMLOG_INDENT" "    "
	
	decrease_g_indent
	assert_equals "$G_SHPMLOG_INDENT" "  "
	
	decrease_g_indent
	assert_equals "$G_SHPMLOG_INDENT" ""
}

test_reset_g_indent() {
	local INDENTATION
	INDENTATION="      "
	
	G_SHPMLOG_INDENT="$INDENTATION"
	
	assert_equals "$G_SHPMLOG_INDENT" "$INDENTATION"
	
	reset_g_indent 
	assert_equals "$G_SHPMLOG_INDENT" ""
	
	reset_g_indent
}

test_set_g_indent() {
	local INDENTATION
	INDENTATION="      "

	assert_equals "$G_SHPMLOG_INDENT" ""
	
	INDENTATION="      "
	set_g_indent "$INDENTATION"
	assert_equals "$G_SHPMLOG_INDENT" "$INDENTATION"
	
	reset_g_indent
	assert_equals "$G_SHPMLOG_INDENT" "" 
}

test_download_from_git_to_tmp_folder() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.1.0"

	local ACTUAL_DIR
	ACTUAL_DIR=$(pwd)
	
	cd "$TMP_DIR_PATH"
	
	remove_folder_if_exists "$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	if [[ -d "$TMP_DIR_PATH/$DEP_ARTIFACT_ID" ]]; then
		assert_fail "$TMP_DIR_PATH/$DEP_ARTIFACT_ID already exists"
	fi 

	download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"
	assert_equals "$?" "$TRUE"
	
	if [[ ! -d "$TMP_DIR_PATH/$DEP_ARTIFACT_ID" ]]; then
		assert_fail "fail download from $DEP_ARTIFACT_ID from git to $TMP_DIR_PATH"
	else
		assert_success
	fi 
	
	remove_folder_if_exists "$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	if [[ -d "$TMP_DIR_PATH/$DEP_ARTIFACT_ID" ]]; then
		assert_fail "fail remove $TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	fi 
	
	cd "$ACTUAL_DIR"
}

test_set_dependency_repository() {
	remove_folder_if_exists "$TMP_DIR_PATH/sh-project-only-4tests"
	
	download_from_git_to_tmp_folder "github.com/sh-pm" "sh-project-only-4tests" "v0.1.0"
	
	# -- DO Override shpm bootstrap load with sh-project-only-4tests bootstrap load -- 
	ROOT_DIR_PATH="$TMP_DIR_PATH/sh-project-only-4tests"
	LIB_DIR_PATH="$ROOT_DIR_PATH/$LIB_DIR_SUBPATH"
	SRC_DIR_PATH="$ROOT_DIR_PATH/$SRC_DIR_SUBPATH"
	TARGET_DIR_PATH="$ROOT_DIR_PATH/$TARGET_DIR_SUBPATH"
	source "$ROOT_DIR_PATH/pom.sh"	
	# -- -----------------------------------------------------------------------------
	
	assert_equals "${#DEPENDENCIES[@]}" "4" || assert_fail "Problem override content of original pom.sh"	

	local SHPM_REPOSITORY
	
	assert_equals "" "$SHPM_REPOSITORY"
	
	set_dependency_repository "sh-pm" SHPM_REPOSITORY
	
	assert_equals "github.com/sh-pm" "$SHPM_REPOSITORY"
	
	# -- UNDO Override shpm bootstrap load with sh-project-only-4tests bootstrap load --
	ROOT_DIR_PATH="$ACTUAL_ROOT_DIR_PATH"
	LIB_DIR_PATH="$ACTUAL_LIB_DIR_PATH"
	SRC_DIR_PATH="$ACTUAL_SRC_DIR_PATH"
	TARGET_DIR_PATH="$ACTUAL_TARGET_DIR_PATH"
	source "$ROOT_DIR_PATH/pom.sh"
	#-----------------------------------------------------------------------------------
	
	assert_equals "${#DEPENDENCIES[@]}" "2" || assert_fail "Problem restore/reload content of original pom.sh to undo override changes"
}

test_set_dependency_version() {
	remove_folder_if_exists "$TMP_DIR_PATH/sh-project-only-4tests"
	
	download_from_git_to_tmp_folder "github.com/sh-pm" "sh-project-only-4tests" "v0.1.0"
	
	# -- DO Override shpm bootstrap load with sh-project-only-4tests bootstrap load -- 
	ROOT_DIR_PATH="$TMP_DIR_PATH/sh-project-only-4tests"
	LIB_DIR_PATH="$ROOT_DIR_PATH/$LIB_DIR_SUBPATH"
	SRC_DIR_PATH="$ROOT_DIR_PATH/$SRC_DIR_SUBPATH"
	TARGET_DIR_PATH="$ROOT_DIR_PATH/$TARGET_DIR_SUBPATH"
	source "$ROOT_DIR_PATH/pom.sh"	
	# -- -----------------------------------------------------------------------------
	
	assert_equals "${#DEPENDENCIES[@]}" "4" || assert_fail "Problem override content of original pom.sh"	

	local SHPM_DEP_VERSION
	
	assert_equals "" "$SHPM_DEP_VERSION"
	
	set_dependency_version "sh-pm" SHPM_DEP_VERSION
	
	assert_equals "v4.1.0" "$SHPM_DEP_VERSION"
	
	# -- UNDO Override shpm bootstrap load with sh-project-only-4tests bootstrap load --
	ROOT_DIR_PATH="$ACTUAL_ROOT_DIR_PATH"
	LIB_DIR_PATH="$ACTUAL_LIB_DIR_PATH"
	SRC_DIR_PATH="$ACTUAL_SRC_DIR_PATH"
	TARGET_DIR_PATH="$ACTUAL_TARGET_DIR_PATH"
	source "$ROOT_DIR_PATH/pom.sh"
	#-----------------------------------------------------------------------------------
	
	assert_equals "${#DEPENDENCIES[@]}" "2" || assert_fail "Problem restore/reload content of original pom.sh to undo override changes"
}

test_compile_sh_project() {
	assert_fail "fkjlsa"
}

run_all_tests_in_this_script