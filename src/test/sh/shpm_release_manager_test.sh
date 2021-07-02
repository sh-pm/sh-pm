#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/shpm_test_base.sh"

# ======================================
# SUT
# ======================================
include_file "$SRC_DIR_PATH/shpm_release_manager.sh"

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

test_clean_release() {
	local PROJECT_DIR
	local PROJECT_TARGET_DIR
	local PROJECT_RELEASES_DIR
	local RESULT
	
	download_from_git_to_tmp_folder "github.com/sh-pm" "sh-project-only-4tests" "$PROJECTVERSION_4TEST"
	
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



test_run_release_package() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"

	remove_file_and_folders_4tests

	download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"
	assert_equals "$?" "$TRUE" || assert_fail "fail download from git to tmp folder."
	
	change_execution_to_project "sh-project-only-4tests"
	
	clean_release 
	
	#run_release_package ## TODO: INFINITE LOOP BECAULSE THIS RUN ALL TESTS AGAIN!!!
	
	if [[ ! -f "$TARGET_DIR_PATH/$DEP_ARTIFACT_ID""-""$DEP_VERSION"".tar.gz" ]]; then
		assert_fail "fail in compile: file *.tar.gz not generated!"
	else
		assert_true
	fi
	
	undo_change_execution_to_project
	assert_equals "$( basename "$ROOT_DIR_PATH" )" "sh-pm" || assert_fail "Problem restore/reload content to undo override changes"
	
	remove_file_and_folders_4tests
}

test_publish_release() {
	assert_fail "Not implement yet!"
}