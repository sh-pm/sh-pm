
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# main.sh
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>







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
				shift # this discard 1st param and do $@ consider params from 2nd param to end
				run_testcases "$@" 				
			fi
			
			if [[ "$ARG" == "coverage" ]];  then
				run_coverage_analysis
			fi
						
			if [[ "$ARG" == "compile_app" ]];  then				
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
				
				run_compile_app "$SKIP_SHELLCHECK"
			fi
			
			if [[ "$ARG" == "compile_lib" ]];  then				
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
				
				run_compile_lib "$SKIP_SHELLCHECK"
			fi
		
			if [[ "$ARG" == "package" ]];  then
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
				
				run_release_package
			fi
			
			if [[ "$ARG" == "publish" ]];  then
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
				
				run_publish_release				
			fi
		done
	fi
}

evict_catastrophic_remove || exit 1

run_sh_pm "$@"


