#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/base/shpm_test_base.sh"

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

test_get_entrypoint_filename() {
	local OBTAINED
	local EXPECTED
	
	EXPECTED="main.sh"
	OBTAINED=$( get_entrypoint_filename )
	
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
	local EXPECTED
	local OBTAINED
	
	EXPECTED="#####################################################################################################################################"
	OBTAINED=$( get_file_separator_delimiter_line )
	
	assert_equals "$EXPECTED" "$OBTAINED"
}

test_remove_unwanted_lines_in_compilation() {
	local FILE4TEST="remove_unwanted_lines_file4test.sh"	
	local INPUT_FILE="$TMP_DIR_PATH/$FILE4TEST"
	local OUTPUT_FILE="$TMP_DIR_PATH/output_file.sh"
	
	cp "$TEST_RESOURCES_DIR_PATH/$FILE4TEST" "$TMP_DIR_PATH/$FILE4TEST" 

	remove_file_if_exists "$OUTPUT_FILE"  
	
	remove_unwanted_lines_in_compilation "$INPUT_FILE" "$OUTPUT_FILE"
	
	remove_file_if_exists "$INPUT_FILE"
	
	local CONTENT=$( grep -v -e '^$' < "$OUTPUT_FILE" ) # read all non blank lines
	
	assert_equals "$CONTENT" "test123" # only 1 line was read, other lines was removed
}

test_ensure_newline_at_end_of_files(){
	local FILENAME4TEST1="file4test1_ensure_newline_at_end_of_files.sh"
	local FILENAME4TEST2="file4test2_ensure_newline_at_end_of_files.sh"
	
	local FOLDERNAME4TEST="folder4test"
	local INPUT_FOLDER="$TMP_DIR_PATH/$FOLDERNAME4TEST"
	
	local CONTENT
	
	remove_folder_if_exists "$INPUT_FOLDER" 
	create_path_if_not_exists "$INPUT_FOLDER"
	
	cp "$TEST_RESOURCES_DIR_PATH/$FILENAME4TEST1" "$INPUT_FOLDER"
	cp "$TEST_RESOURCES_DIR_PATH/$FILENAME4TEST2" "$INPUT_FOLDER" 

	ensure_newline_at_end_of_files "$INPUT_FOLDER"
	 
	CONTENT=$( tail -n 1 "$INPUT_FOLDER/$FILENAME4TEST1" ) # read last line
	assert_equals "$CONTENT" ""
	
	CONTENT=$( tail -n 1 "$INPUT_FOLDER/$FILENAME4TEST2" ) # read last line
	assert_equals "$CONTENT" "" 
	
	#remove_folder_if_exists "$INPUT_FOLDER" 
}

test_prepare_libraries() {
	local TMP_COMPILE_WORKDIR
	
	TMP_COMPILE_WORKDIR=$( get_tmp_compilation_dir )
	FILE_WITH_CAT_SH_LIBS="$TMP_COMPILE_WORKDIR/lib_files_concat"
	
	prepare_libraries "$LIB_DIR_PATH" "$FILE_WITH_CAT_SH_LIBS"
	
	if [[ ! -d "$TMP_COMPILE_WORKDIR" ]]; then
	  assert_fail "Folder $TMP_COMPILE_WORKDIR not found."
	fi
	
	if [[ ! -f "$FILE_WITH_CAT_SH_LIBS" ]]; then
	  assert_fail "File $FILE_WITH_CAT_SH_LIBS not found."
	fi
}

test_create_tmp_file_to_store_file_separator() {
	local DESCRIPTION="aux4test"
	local PATH_TO_TMP_FILE_STORE_SEPARATOR="/tmp/aux4test.sh"
	
	local EXPECTED="#### aux4test ######################################################################################################"
	local OBTAINED
	
	remove_file_if_exists "$PATH_TO_TMP_FILE_STORE_SEPARATOR"
	
	create_tmp_file_to_store_file_separator "$DESCRIPTION" "$PATH_TO_TMP_FILE_STORE_SEPARATOR"
	
	OBTAINED=$( cat "$PATH_TO_TMP_FILE_STORE_SEPARATOR" )
	
	assert_equals "$EXPECTED" "$OBTAINED"
	
	remove_file_if_exists "$PATH_TO_TMP_FILE_STORE_SEPARATOR"
}

test_create_tmp_file_to_store_section_separator() {
	local DESCRIPTION="aux4test"
	local PATH_TO_TMP_FILE_STORE_SEPARATOR="/tmp/aux4test.sh"
	
	local EXPECTED=$( echo -e "\n#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n# aux4test\n#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n" )
	local OBTAINED
	
	remove_file_if_exists "$PATH_TO_TMP_FILE_STORE_SEPARATOR"
	
	create_tmp_file_to_store_section_separator "$DESCRIPTION" "$PATH_TO_TMP_FILE_STORE_SEPARATOR"
	
	OBTAINED=$( cat "$PATH_TO_TMP_FILE_STORE_SEPARATOR" )
	
	assert_equals "$EXPECTED" "$OBTAINED"
	
	remove_file_if_exists "$PATH_TO_TMP_FILE_STORE_SEPARATOR"
}

test_add_section_delimiter_at_start_of_file() {
	local SECTION_DESCRIPTION="aux4test"
	local FILE_PATH="/tmp/test.sh"
	
	local INITIAL_FILE_CONTENT
	local SECTION_DELIMITER
	
	remove_file_if_exists "$FILE_PATH"
	
	INITIAL_FILE_CONTENT="test123"
	
	echo -e "$INITIAL_FILE_CONTENT" > "$FILE_PATH"
	
	OBTAINED=$( cat "$FILE_PATH" )
	assert_equals "$INITIAL_FILE_CONTENT" "$OBTAINED"
	
	SECTION_DELIMITER=$( echo -e "\n#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n# aux4test\n#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n" )
	
	local EXPECTED="$SECTION_DELIMITER\n\n$INITIAL_FILE_CONTENT"
	local OBTAINED
	
	add_section_delimiter_at_start_of_file "$SECTION_DESCRIPTION" "$FILE_PATH"

	OBTAINED=$( cat "$FILE_PATH" )
	
	assert_equals "$EXPECTED" "$OBTAINED"
	
	remove_file_if_exists "$FILE_PATH"
}

test_run_compile_app() {
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
