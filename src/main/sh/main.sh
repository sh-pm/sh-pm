#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-unit

include_file "$SRC_DIR_PATH/shpm_evict_catastrophic_remove.sh"

include_file "$SRC_DIR_PATH/shpm_file_utils.sh"
include_file "$SRC_DIR_PATH/shpm_log_utils.sh"
include_file "$SRC_DIR_PATH/shpm_git_api.sh"

include_file "$SRC_DIR_PATH/shpm_compiler.sh"
include_file "$SRC_DIR_PATH/shpm_coverage.sh"
include_file "$SRC_DIR_PATH/shpm_shellcheck.sh"
include_file "$SRC_DIR_PATH//shpm_package_manager.sh"
include_file "$SRC_DIR_PATH//shpm_testcases_runner.sh"
include_file "$SRC_DIR_PATH//shpm_release_manager.sh"

print_help() {
  	local SCRIPT_NAME
    SCRIPT_NAME="$ARTIFACT_ID"

    echo "SH-PM: Shell Script Package Manager"
	echo ""
	echo "USAGE:"
	echo "  [$SCRIPT_NAME] [OPTION]"
	echo ""
	echo "OPTIONS:"
    echo "  update                Download dependencies in local repository $LIB_DIR_SUBPATH"
	echo "  init                  Create expecte sh-pm project structure with files and folders " 
	echo "  clean                 Clean $TARGET_DIR_PATH folder"
    echo "  lint                  Run ShellCheck (if exists) in $SRC_DIR_SUBPATH folder"
    echo "  test                  Run sh-unit tests in $TEST_DIR_SUBPATH folder"
	echo "  coverage              Show sh-unit test coverage"
    echo "  package               Create compressed file in $TARGET_DIR_PATH folder"
    echo "  publish               Publish code and builded file in GitHub repositories (remote and local)"
	echo ""
	echo "EXAMPLES:"
	echo "  ./shpm update"
	echo ""
	echo "  ./shpm init"
	echo ""
	echo "  ./shpm package"
	echo ""
	echo "  ./shpm publish"
	echo ""
}

run_sh_pm() {
	if [ $# -eq 0 ];  then
		print_help
		exit 1
	else
		for (( i=1; i <= $#; i++)); do	
	        ARG="${!i}"
	
			if [[ "$ARG" == "update" ]];  then
				run_update_dependencies	"$VERBOSE"
			fi
			
			if [[ "$ARG" == "init" ]];  then
				run_init_project_structure
			fi
			
			if [[ "$ARG" == "clean" ]];  then
				run_clean_release "$ROOT_DIR_PATH"
			fi

			if [[ "$ARG" == "lint" ]];  then
				run_shellcheck
			fi
			
			if [[ "$ARG" == "test" ]];  then
				TEST="true"				
				shift # this discard 1st param and do $@ consider params from 2nd param to end
				run_testcases "$@" 				
			fi
			
			if [[ "$ARG" == "coverage" ]];  then
				run_coverage_analysis
			fi
						
			if [[ "$ARG" == "compile_app" ]];  then				
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
				
				run_compile_app
			fi
			
			if [[ "$ARG" == "compile_lib" ]];  then				
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
				
				run_compile_lib
			fi
		
			if [[ "$ARG" == "package" ]];  then
				PACKAGE="true"
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
				
				run_release_package
			fi
			
			if [[ "$ARG" == "publish" ]];  then
				PUBLISH="true"
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
				
				run_publish_release				
			fi
		done
	fi
}

evict_catastrophic_remove || exit 1

run_sh_pm "$@"
