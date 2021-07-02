#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/shpm_test_base.sh"

# ======================================
# SUT
# ======================================
include_file "$SRC_DIR_PATH/shpm_git_api.sh"

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

test_git_clone() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"

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


test_download_from_git_to_tmp_folder() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"

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

test_create_new_remote_branch_from_master_branch() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION

	local NEW_BRANCH_NAME
	
	GITHUB_HOST="github.com"
	GITHUB_USER="sh-pm"
	REPOSITORY="$GITHUB_HOST/$GITHUB_USER"
	
	remove_file_and_folders_4tests

	download_from_git_to_tmp_folder "$REPOSITORY" "$PROJECTNAME_4TEST" "$PROJECTVERSION_4TEST"
	assert_equals "$?" "$TRUE" "Function download_from_git_to_tmp_folder succesfully executed"
	
	change_execution_to_project "$PROJECTNAME_4TEST"
	assert_equals "$ROOT_DIR_PATH" "$TMP_DIR_PATH/$PROJECTNAME_4TEST" "Ensure that ROOT_DIR_PATH global var was changed to $TMP_DIR_PATH/$PROJECTNAME_4TEST"
	
	cd "$ROOT_DIR_PATH" || exit 1
	assert_equals "$(pwd)" "$TMP_DIR_PATH/$PROJECTNAME_4TEST" "Ensure that test run inside $TMP_DIR_PATH/$PROJECTNAME_4TEST"
	
	# Cause some modification in some file of project
	echo $( date +"%Y%m%d_%H%M%S_%s" ) >> "$CHANGELOG_4TEST"

	#read_git_username_and_password 
	
	create_new_remote_branch_from_master_branch \
	  "$GITHUB_HOST" \
	  "$GITHUB_USER" \
	  "$PROJECTNAME_4TEST" \
	  "$GITHUB_USER" \
	  "$GIT_REMOTE_PASSWORD" \
	  "$PROJECTVERSION_4TEST" \
	  "$NEWBRANCH_4TEST"
	
	NEW_REMOTE_BRANCH=$( git branch -r | grep "origin/$NEWBRANCH_4TEST" | xargs )
	assert_equals "$NEW_REMOTE_BRANCH" "origin/$NEWBRANCH_4TEST" "Check if branch was create in remote git repo"
	
	echo "Deleting local $NEWBRANCH_4TEST branch"
	git branch -D "$NEWBRANCH_4TEST"
	
	echo "Deleting remote $NEWBRANCH_4TEST branch"
	git push origin --delete "origin/$NEWBRANCH_4TEST"
	
	undo_change_execution_to_project
	assert_equals "$( basename "$ROOT_DIR_PATH" )" "sh-pm" || assert_fail "Problem restore/reload content to undo override changes"
	
	remove_file_and_folders_4tests
}