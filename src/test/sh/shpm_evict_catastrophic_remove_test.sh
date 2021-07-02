#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/shpm_test_base.sh"

# ======================================
# SUT
# ======================================
include_file "$SRC_DIR_PATH/shpm_evict_catastrophic_remove.sh"

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