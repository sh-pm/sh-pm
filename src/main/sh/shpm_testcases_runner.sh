run_testcases() {
	shpm_log_operation "Searching unit test files to run ..."
	
	if [[ -d "$TEST_DIR_PATH" ]]; then
	
		local ALL_TEST_FILES
		ALL_TEST_FILES=( $(ls "$TEST_DIR_PATH"/*_test.sh 2> /dev/null) );
		
		local TEST_FUNCTIONS 
		TEST_FILTERS=( "$@" )
		
		shpm_log "Found ${#ALL_TEST_FILES[@]} test file(s)" 
		shpm_log "\nStart execution of files ...\n"
		
		run_testcases_in_files ALL_TEST_FILES TEST_FILTERS
	
	else 
		shpm_log "Nothing to test"
	fi
	
	shpm_log "Done"
}
