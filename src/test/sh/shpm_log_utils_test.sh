#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit
include_file "$TEST_DIR_PATH/shpm_test_base.sh"

# ======================================
# SUT
# ======================================
include_file "$SRC_DIR_PATH/shpm_log_utils.sh"

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
