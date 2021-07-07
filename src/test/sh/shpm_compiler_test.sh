#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/shpm_test_base.sh"

# ======================================
# SUT
# ======================================
include_file "$SRC_DIR_PATH/shpm_compiler.sh"

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

test_get_entry_point_file() {
	local OBTAINED
	local EXPECTED
	
	EXPECTED="main.sh"
	OBTAINED=$( get_entry_point_file )
	
	assert_equals "$EXPECTED" "$OBTAINED"
}

test_get_compiled_filename() {
	local OBTAINED
	local EXPECTED
	
	EXPECTED="sh-pm.sh"
	OBTAINED=$( get_compiled_filename )
	
	assert_equals "$EXPECTED" "$OBTAINED"
}

test_array_contain_element() {
	local ARRAY
	local E1
	local E2
	local E3
	local E4
	
	E1="test_getxpto1"
	E2="test_getxpto2"
	E3="test_getxpto3"
	E4="FDJSAFDLSAK" # NOT IN ARRAY
	
	ARRAY=( "$E1" "$E2" "$E3" ) 
	
	array_contain_element ARRAY "$E1"
	assert_equals "$?" "$TRUE" "Array contains $E1 element"
	
	array_contain_element ARRAY "$E2"
	assert_equals "$?" "$TRUE" "Array contains $E2 element"
	
	array_contain_element ARRAY "$E3"
	assert_equals "$?" "$TRUE" "Array contains $E3 element"
	
	array_contain_element ARRAY "$E4"
	assert_equals "$?" "$FALSE" "Array NOT contains $E4 element"
}

test_right_pad_string() {
	local EXPECTED
	local OBTAINED
	
	EXPECTED="#####################################################################################################################################"
	OBTAINED=$( right_pad_string "" 133 "#" )
	assert_equals "$EXPECTED" "$OBTAINED"
	
	EXPECTED=""
	OBTAINED=$( right_pad_string "" 0 "#" )	
	assert_equals "$EXPECTED" "$OBTAINED"
	
	EXPECTED="test------"
	OBTAINED=$( right_pad_string "test" 10 "-" )	
	assert_equals "$EXPECTED" "$OBTAINED"
}

test_left_pad_string() {
	local EXPECTED
	local OBTAINED
	
	EXPECTED="#####################################################################################################################################"
	OBTAINED=$( left_pad_string "" 133 "#" )
	assert_equals "$EXPECTED" "$OBTAINED"
	
	EXPECTED=""
	OBTAINED=$( left_pad_string "" 0 "#" )	
	assert_equals "$EXPECTED" "$OBTAINED"
	
	EXPECTED="------test"
	OBTAINED=$( left_pad_string "test" 10 "-" )	
	assert_equals "$EXPECTED" "$OBTAINED"
		
	EXPECTED="--------\n"
	OBTAINED=$( left_pad_string "\n" 10 "-" )	
	assert_equals "$EXPECTED" "$OBTAINED"
}

test_get_file_separator_delimiter_line() {
	EXPECTED="\n###################################################################################################################################\n"
	OBTAINED=$( get_file_separator_delimiter_line )
	assert_equals "$EXPECTED" "$OBTAINED"
}

test_run_compile_sh_project() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"

	remove_folder_if_exists "$TMP_DIR_PATH/$DEP_ARTIFACT_ID"

	download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"
	assert_equals "$?" "$TRUE" || assert_fail "fail download from git to tmp folder."
	
	change_execution_to_project "sh-project-only-4tests"		
	
	clean_release "$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	assert_equals "$?" "$TRUE" || assert_fail "clean release failed."
	if [[ ! -d "/tmp/sh-project-only-4tests" ]]; then
	  assert_fail "project folder not found."
	fi
	
	run_compile_sh_project
	assert_equals "$?" "$TRUE" || assert_fail "compilation failed."
	
	COMPILED_FILE_CONTENT_EXPECTED="$TEST_RESOURCES_DIR_PATH/sh-project-only-4tests.sh_compiled_file_expected"
	COMPILED_FILE_CONTENT_OBTAINED="$TARGET_DIR_PATH/sh-project-only-4tests.sh"
	
	sleep 3
	
	file "$COMPILED_FILE_CONTENT_EXPECTED" && assert_success|| assert_fail "fail create compiled file"
	
	file "$COMPILED_FILE_CONTENT_OBTAINED" && assert_success || assert_fail "expected file in test not found"
	
	diff -b "$COMPILED_FILE_CONTENT_EXPECTED" "$COMPILED_FILE_CONTENT_OBTAINED"
	assert_equals "$?" "$TRUE" || assert_fail "compile file content not equals to content file expected" 
		
	undo_change_execution_to_project
	assert_equals "${#DEPENDENCIES[@]}" "2" || assert_fail "Problem restore/reload content of original pom.sh to undo override changes"
}
