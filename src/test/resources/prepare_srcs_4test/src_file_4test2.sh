#!/bin/bash

source ./bootstrap.sh

include_lib somelib
include_file "/a/b/c/file"

create_path_if_not_exists2() {
	local PATH_TARGET
	PATH_TARGET="$1"
	
	if [[ -z "$PATH_TARGET" ]]; then
		shpm_log "${FUNCNAME[0]} run with empty param: |$PATH_TARGET|"
		return 1
	fi 

	if [[ ! -d "$PATH_TARGET" ]]; then
	   shpm_log "- Creating $PATH_TARGET ..."
	   mkdir -p "$PATH_TARGET"
	fi
}