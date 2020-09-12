#!/bin/bash

debug_var() {
	local ENABLE_DEBUG="false"
	if [[ "$ENABLE_DEBUG" == "true" ]]; then
		echo $1
	fi
}

if [[ -z $SRC_DIR_SUBPATH ]]; then
	SRC_DIR_SUBPATH=src/main/sh
	LIB_DIR_SUBPATH=src/lib/sh
	TEST_DIR_SUBPATH=src/test/sh
fi

if [[ -z $ROOT_DIR_PATH ]]; then
	THIS_SCRIPT_PATH=$( dirname $(realpath "${BASH_SOURCE[0]}}") )
	ROOT_DIR_PATH=${THIS_SCRIPT_PATH//$SRC_DIR_SUBPATH/}		
	debug_var "ROOT_DIR_PATH: $ROOT_DIR_PATH"
fi

if [[ -z $SRC_DIR_PATH ]]; then
	SRC_DIR_PATH=$ROOT_DIR_PATH/$SRC_DIR_SUBPATH
	debug_var "SRC_DIR_PATH: $SRC_DIR_PATH"
fi

if [[ -z $LIB_DIR_PATH ]]; then
	LIB_DIR_PATH=$ROOT_DIR_PATH/$LIB_DIR_SUBPATH
	debug_var "LIB_DIR_PATH: $LIB_DIR_PATH"
fi

if [[ -z $TEST_DIR_PATH ]]; then
	TEST_DIR_PATH=$ROOT_DIR_PATH/$TEST_DIR_SUBPATH
	debug_var "TEST_DIR_PATH: $TEST_DIR_PATH"
fi

if [[ -z $TARGET_DIR_PATH ]]; then
	TARGET_DIR_PATH=$ROOT_DIR_PATH/target
	debug_var "TARGET_DIR_PATH: $TARGET_DIR_PATH"
fi

