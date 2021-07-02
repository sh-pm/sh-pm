#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/shpm_test_base.sh"

# ======================================
# SUT
# ======================================
include_file "$SRC_DIR_PATH/shpm_package_manager.sh"

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

test_update_dependency() {

	local DEP_NAME
	local DEP_VERSION
	
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"
	
	remove_folder_if_exists "$TMP_DIR_PATH/sh-project-only-4tests"
	
	download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"
	
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
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"
	
	remove_folder_if_exists "$TMP_DIR_PATH/sh-project-only-4tests"
	
	download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"
	
	# -- DO Override shpm bootstrap load with sh-project-only-4tests bootstrap load -- 
	ROOT_DIR_PATH="$TMP_DIR_PATH/sh-project-only-4tests"
	LIB_DIR_PATH="$ROOT_DIR_PATH/$LIB_DIR_SUBPATH"
	SRC_DIR_PATH="$ROOT_DIR_PATH/$SRC_DIR_SUBPATH"
	TARGET_DIR_PATH="$ROOT_DIR_PATH/$TARGET_DIR_SUBPATH"
	source "$ROOT_DIR_PATH/pom.sh"	
	# -- -----------------------------------------------------------------------------
	
	assert_equals "${#DEPENDENCIES[@]}" "4" || assert_fail "Problem override content of original pom.sh"
	
	update_dependencies
	
	if [[ ! -d "$LIB_DIR_PATH/sh-pm-v4.2.0" ]]; then
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
	
	if [[ ! -d "$LIB_DIR_PATH/sh-unit-v1.5.8" ]]; then
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

test_set_dependency_repository() {
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"

	remove_folder_if_exists "$TMP_DIR_PATH/sh-project-only-4tests"
	
	download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"
	
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
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY="github.com/sh-pm"
	DEP_ARTIFACT_ID="sh-project-only-4tests"
	DEP_VERSION="v0.2.0"

	remove_folder_if_exists "$TMP_DIR_PATH/sh-project-only-4tests"
	
	download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION"
	
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
	
	assert_equals "v4.2.0" "$SHPM_DEP_VERSION"
	
	# -- UNDO Override shpm bootstrap load with sh-project-only-4tests bootstrap load --
	ROOT_DIR_PATH="$ACTUAL_ROOT_DIR_PATH"
	LIB_DIR_PATH="$ACTUAL_LIB_DIR_PATH"
	SRC_DIR_PATH="$ACTUAL_SRC_DIR_PATH"
	TARGET_DIR_PATH="$ACTUAL_TARGET_DIR_PATH"
	source "$ROOT_DIR_PATH/pom.sh"
	#-----------------------------------------------------------------------------------
	
	assert_equals "${#DEPENDENCIES[@]}" "2" || assert_fail "Problem restore/reload content of original pom.sh to undo override changes"
}