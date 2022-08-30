#!/usr/bin/env bash

# =================================
# Internal Log
# =================================
# ---------------------------------
# Enable/Disable internal log utility for dev debug purposes, 
# BUT without create circular dependency between bootstrap.sh.
# and sh-logger library; 
# Globals:
#   None
# Arguments:
#   $1 - text to be logged in dev debug of bootstrap.sh
# ---------------------------------
internal_debug() {
	local enable_debug
	enable_debug="false"
	
	if [[ "$enable_debug" == "true" ]]; then
		echo "$1"
	fi
}

# =================================
# Mandatory Global Variables
# =================================
# -- bootstrap file name: name of this file -----
BOOTSTRAP_FILENAME="$(basename "${BASH_SOURCE[0]}")"
export BOOTSTRAP_FILENAME

# -- dependencies file name ----------
export DEPENDENCIES_FILENAME="deps.sh"

# -- "Boolean's" ------------------
export readonly TRUE=0
export readonly FALSE=1

# -- Test Coverage ----------------
export MIN_PERCENT_TEST_COVERAGE=80

# -- Main SubPath's ---------------
if [[ -z "$SRC_DIR_SUBPATH" ]]; then
	export SRC_DIR_SUBPATH="src/main/sh"
fi

if [[ -z "$SRC_RESOURCES_DIR_SUBPATH" ]]; then
	export SRC_RESOURCES_DIR_SUBPATH="src/main/resources"
fi

if [[ -z "$LIB_DIR_SUBPATH" ]]; then
	export LIB_DIR_SUBPATH="src/lib/sh"
fi

if [[ -z "$TEST_DIR_SUBPATH" ]]; then
	export TEST_DIR_SUBPATH="src/test/sh"
fi

if [[ -z "$TEST_RESOURCES_DIR_SUBPATH" ]]; then
	export TEST_RESOURCES_DIR_SUBPATH="src/test/resources"
fi

if [[ -z "$TARGET_DIR_SUBPATH" ]]; then
	export TARGET_DIR_SUBPATH="target"
fi

# -- Main Path's ------------------
if [[ -z "$ROOT_DIR_PATH" ]]; then
	THIS_SCRIPT_FOLDER_PATH="$( dirname "$(realpath "${BASH_SOURCE[0]}")" )"
	export THIS_SCRIPT_FOLDER_PATH
	
	ROOT_DIR_PATH="${THIS_SCRIPT_FOLDER_PATH//$SRC_DIR_SUBPATH/}"
	export ROOT_DIR_PATH
			
	internal_debug "ROOT_DIR_PATH: $ROOT_DIR_PATH"
fi

if [[ -z "$SRC_RESOURCES_DIR_PATH" ]]; then
	export SRC_RESOURCES_DIR_PATH="$ROOT_DIR_PATH/$SRC_RESOURCES_DIR_SUBPATH"
	internal_debug "SRC_RESOURCES_DIR_PATH: $SRC_RESOURCES_DIR_PATH"
fi

if [[ -z "$SRC_DIR_PATH" ]]; then
	export SRC_DIR_PATH="$ROOT_DIR_PATH/$SRC_DIR_SUBPATH"
	internal_debug "SRC_DIR_PATH: $SRC_DIR_PATH"
fi

if [[ -z "$LIB_DIR_PATH" ]]; then
	export LIB_DIR_PATH="$ROOT_DIR_PATH/$LIB_DIR_SUBPATH"
	internal_debug "LIB_DIR_PATH: $LIB_DIR_PATH"
fi

if [[ -z "$TEST_DIR_PATH" ]]; then
	export TEST_DIR_PATH="$ROOT_DIR_PATH/$TEST_DIR_SUBPATH"
	internal_debug "TEST_DIR_PATH: $TEST_DIR_PATH"
fi

if [[ -z "$TEST_RESOURCES_DIR_PATH" ]]; then
	export TEST_RESOURCES_DIR_PATH="$ROOT_DIR_PATH/$TEST_RESOURCES_DIR_SUBPATH"
	internal_debug "TEST_RESOURCES_DIR_PATH: $TEST_RESOURCES_DIR_PATH"
fi

if [[ -z "$TARGET_DIR_PATH" ]]; then
	export TARGET_DIR_PATH="$ROOT_DIR_PATH/$TARGET_DIR_SUBPATH"
	internal_debug "TARGET_DIR_PATH: $TARGET_DIR_PATH"
fi

if [[ -z "$TMP_DIR_PATH" ]]; then
    # WARNING: Used in 
    #   - secure rm -rf executions
    #   - unit tests
	export TMP_DIR_PATH="/tmp"
	internal_debug "TMP_DIR_PATH: $TMP_DIR_PATH"
	
fi

if [[ -z "$STDOUT_REDIRECT_FILEPATH_4TEST" ]]; then
	export STDOUT_REDIRECT_FILENAME_4TEST="stdout_redirect_4test"
	export ENABLE_STDOUT_REDIRECT_4TEST="$FALSE"

	export STDOUT_REDIRECT_FILEPATH_4TEST="$TMP_DIR_PATH/$STDOUT_REDIRECT_FILENAME_4TEST"
fi

# -- files, folders, branchs, etc for unit tests -------------------
export FOLDERNAME_4TEST="folder4test"
export FILENAME_4TEST="file4test"
export PROJECTNAME_4TEST="sh-project-only-4tests"	
export PROJECTVERSION_4TEST="v0.2.0"
export NEWBRANCH_4TEST="newbranch4test"
export CHANGELOG_4TEST="changelog4test"

# -- manifest file -------------------
export MANIFEST_FILENAME="manifest"
export MANIFEST_FILE_PATH="$SRC_RESOURCES_DIR_PATH/$MANIFEST_FILENAME"
export MANIFEST_P_ENTRY_POINT_FILE="entry_point_file"
export MANIFEST_P_ENTRY_POINT_FUNCTION="entry_point_function"

# =================================
# echo -e colors
# =================================
export ECHO_COLOR_ESC_CHAR='\033'
export ECHO_COLOR_RED=$ECHO_COLOR_ESC_CHAR'[0;31m'
export ECHO_COLOR_YELLOW=$ECHO_COLOR_ESC_CHAR'[0;93m'
export ECHO_COLOR_GREEN=$ECHO_COLOR_ESC_CHAR'[0;32m'	
export ECHO_COLOR_NC=$ECHO_COLOR_ESC_CHAR'[0m' # No Color

# =================================
# Load dependencies
# =================================
. "$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME"

# =================================
# Include Management Libs and Files
# =================================

if [[ -z ${DEPS_INCLUDED+x}  ]]; then
	declare -A DEPS_INCLUDED=( \
		
	);
fi

if [[ -z ${FILES_INCLUDED+x}  ]]; then
	declare -A FILES_INCLUDED=( \
		
	);
fi

# ---------------------------------
# Include all files of a library
# Depend of function include_file.
#
# Globals:
#   DEPS_INCLUDED
# Arguments:
#   $1 - Name of library to be included
# ---------------------------------
function include_lib () {
    
    local lib_to_include
    
    lib_to_include="$1"
    
    # Sanitize param
	if [[ -z "$lib_to_include" ]]; then
		echo "(ER0002) Could't perform include_lib: function receive empty param." >&2
		exit 1
	fi
	
	# Validate include
	# Include library only one time
	if [[ -n "${DEPS_INCLUDED[$lib_to_include]}" ]]; then
		internal_debug "include_lib: lib $lib_to_include already included."
	fi
	
	local dep_version
	dep_version=$( echo "${DEPENDENCIES[$lib_to_include]}" | cut -d "@" -f 1 | xargs ) #xargs is to trim string!
		
	local dep_folder_path
	dep_folder_path="$LIB_DIR_PATH/$lib_to_include""-""$dep_version"
	
	if [[ ! -d "$dep_folder_path" ]]; then
		echo "(ER0003) Could't perform include_lib: $lib_to_include not exists in local $LIB_DIR_PATH repository." >&2
		exit 1
	fi
	
	for sh_file in "$LIB_DIR_PATH/$lib_to_include""-""$dep_version"/*; do
	    if [[ "$(basename "$sh_file")" != "$DEPENDENCIES_FILENAME" && "$(basename "$sh_file")" != "$BOOTSTRAP_FILENAME" ]]; then
			include_file "$sh_file" 
		else
	        internal_debug "$sh_file NOT included" 
		fi
	done
	
	DEPS_INCLUDED[$lib_to_include]=$TRUE
}

# ---------------------------------
# Include the file in absolute path received as param.
#
# Globals:
#   DEPS_INCLUDED
# Arguments:
#   $1 - absolute path to the file to be included
# ---------------------------------
function include_file () {
    
    local filepath_to_include
    
    filepath_to_include="$1"
    
    # Sanitize param
	if [[ -z "$filepath_to_include" ]]; then
		echo "(ER0001) Could't perform include_file: function receive empty param." >&2
		exit 1
	fi
	
	# Validate include
	# Include file only one time
	if [[ -n "${FILES_INCLUDED[$filepath_to_include]}" ]]; then
		internal_debug "$filepath_to_include already included."
	else 
		. "$filepath_to_include"
		
		FILES_INCLUDED[$filepath_to_include]="$TRUE"
		
	    internal_debug "$filepath_to_include included"	
	fi	
}
