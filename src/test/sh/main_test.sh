#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/shpm_test_base.sh"

# ======================================
# SUT
# ======================================
# SPECIAL CASE: because shpm test itself it dont' need load itself!

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



test_init_project_structure() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"

	remove_folder_if_exists "$TMP_DIR_PATH/$FOLDERNAME_4TEST"

	create_path_if_not_exists "$TMP_DIR_PATH/$FOLDERNAME_4TEST"
	touch "$TMP_DIR_PATH/$FOLDERNAME_4TEST/main.sh"
	
	create_path_if_not_exists "$TMP_DIR_PATH/$FOLDERNAME_4TEST/functions"	
	touch "$TMP_DIR_PATH/$FOLDERNAME_4TEST/functions/functions.sh"
	
	sleep 1
	
	change_execution_to_project "$FOLDERNAME_4TEST"
	 
	init_project_structure

	
	if [[ ! -d "$TMP_DIR_PATH/$FOLDERNAME_4TEST/src/main/sh" || ! -d "$TMP_DIR_PATH/$FOLDERNAME_4TEST/src/test/sh" ]]; then
		assert_fail "fail in folders generation."
	else
		assert_true
	fi
	
	if [[ ! -f "$TMP_DIR_PATH/$FOLDERNAME_4TEST/src/main/sh/main.sh" || ! -d "$TMP_DIR_PATH/$FOLDERNAME_4TEST/src/test/sh/functions/functions.sh" ]]; then
		assert_fail "fail in folders generation."
	else
		assert_true
	fi
	
	undo_change_execution_to_project
	assert_equals "$( basename "$ROOT_DIR_PATH" )" "sh-pm" || assert_fail "Problem restore/reload content to undo override changes"
	
	remove_file_and_folders_4tests
}

test_run_coverage_analysis() {
	assert_fail "Not implement yet!"
}

test_do_coverage_analysis() {
	assert_fail "Not implement yet!"
}
