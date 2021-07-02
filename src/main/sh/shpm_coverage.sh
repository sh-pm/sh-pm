run_coverage_analysis() {
	local PERCENT
	local COVERAGE_STR_LOG
	
	shpm_log_operation "Test coverage analysis"
	
	PERCENT=$(do_coverage_analysis)
	
	NOT_HAVE_MINIMUM_COVERAGE=$(echo "${PERCENT} < ${MIN_PERCENT_TEST_COVERAGE}"  | bc -l)
	
	COVERAGE_STR_LOG="$PERCENT%. Minimum is $MIN_PERCENT_TEST_COVERAGE% (Value configured in $BOOTSTRAP_FILENAME)"
	
	if (( "$NOT_HAVE_MINIMUM_COVERAGE" )); then
		
		do_coverage_analysis "-v"
		
		shpm_log ""
		shpm_log "Test Coverage FAIL! $COVERAGE_STR_LOG" "red"
	else
	    shpm_log "Test Coverage OK: $COVERAGE_STR_LOG" "green"
	fi
	
	shpm_log ""
}

do_coverage_analysis() {
	VERBOSE="$1"

	local TOTAL_FILES_ANALYSED_COUNT	
	local TOTAL_FUNCTIONS_FOUNDED_COUNT
	local TOTAL_FUNCTIONS_WITH_TEST_COUNT
	local TOTAL_COVERAGE
	local FILE_FUNCTIONS_COUNT
	local FILE_FUNCTIONS_WITH_TEST_COUNT
	local FILES_ANALYSIS_LOG_SEPARATOR

	TOTAL_FILES_ANALYSED_COUNT=0
	TOTAL_FUNCTIONS_FOUNDED_COUNT=0
	TOTAL_FUNCTIONS_WITH_TEST_COUNT=0
	TOTAL_COVERAGE=0
	FILE_FUNCTIONS_COUNT=0
	FILE_FUNCTIONS_WITH_TEST_COUNT=0
	
	FILES_ANALYSIS_LOG_SEPARATOR="\n----------------------------------------------------------------\n"
	
	if [[ "$VERBOSE" != "-v"  ]]; then
		SHPM_LOG_DISABLED="$TRUE"
	fi
	
	shpm_log ""
	shpm_log "Find src file/functions in SRC_DIR_PATH and respective tests file/functions in TEST_DIR_PATH:"
	shpm_log "  * SRC_DIR_PATH: $SRC_DIR_PATH"
	shpm_log "  * TEST_DIR_PATH: $TEST_DIR_PATH"
	shpm_log ""
	shpm_log "Start test coverage analysis ..."
	shpm_log ""
	
	
	while IFS=  read -r -d $'\0'; do
    	SH_FILES_FOUNDED+=("$REPLY")
	done < <(find "$SRC_DIR_PATH" -name "*.sh" -print0)
	
	TOTAL_FILES_ANALYSED_COUNT="${#SH_FILES_FOUNDED[@]}"
	
	shpm_log "$FILES_ANALYSIS_LOG_SEPARATOR"
	
	for i in "${!SH_FILES_FOUNDED[@]}"; do 
	
	    filepath="${SH_FILES_FOUNDED[$i]}"
	     
		FILE_FUNCTIONS_COUNT=0
		FILE_FUNCTIONS_WITH_TEST_COUNT=0
		 
		increase_g_indent 
		filename="$( basename "$filepath" )"
		
		FUNCTIONS_TO_TEST=( $(grep -E '^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)' "$filepath" | tr \(\)\}\{ ' ' | sed 's/^[ \t]*//;s/[ \t]*$//') );
		FILE_FUNCTIONS_COUNT="${#FUNCTIONS_TO_TEST[@]}"
		TOTAL_FUNCTIONS_FOUNDED_COUNT=$(( TOTAL_FUNCTIONS_FOUNDED_COUNT + FILE_FUNCTIONS_COUNT )) 
		
		test_filename="${filename//.sh/}_test.sh"
		test_filepath="$TEST_DIR_PATH/$test_filename"
		 
		shpm_log "FILE: $filename - Analysis Start"
		
		shpm_log " - Location: $filepath"
		if [[ -f "$test_filepath" ]]; then
	
			shpm_log " - TestedBy: $test_filepath" 
			EXISTING_TEST_FUNCTIONS=( $(grep -E '^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)' "$test_filepath" | tr \(\)\}\{ ' ' | sed 's/^[ \t]*//;s/[ \t]*$//') );
			
			shpm_log " - Function's coverage analysis:"
			
			increase_g_indent 
			increase_g_indent
			increase_g_indent
			
			FILE_FUNCTIONS_WITH_TEST_COUNT=0
			
			for function_name in "${FUNCTIONS_TO_TEST[@]}"; do
				
				foundtest=$FALSE
				for test_function in "${EXISTING_TEST_FUNCTIONS[@]}"; do
					if [[ "$test_function" =~ "test_""$function_name".* ]]; then
						foundtest=$TRUE
						break;
					fi
				done;
				
				if [[ "$foundtest" == "$FALSE" ]]; then
				   shpm_log "$function_name ... NO TEST FOUND!" "red"
				else
					FILE_FUNCTIONS_WITH_TEST_COUNT=$((FILE_FUNCTIONS_WITH_TEST_COUNT + 1))
				   shpm_log "$function_name ... OK, test found." "green"
				fi
				
			done
			
			TOTAL_FUNCTIONS_WITH_TEST_COUNT=$(( TOTAL_FUNCTIONS_WITH_TEST_COUNT + FILE_FUNCTIONS_WITH_TEST_COUNT ))
			
			decrease_g_indent 
			decrease_g_indent
			decrease_g_indent
			
		else		
			shpm_log " - TestedBy: NO FILE TEST FOUND!" "red"
			
			increase_g_indent 
			increase_g_indent
			increase_g_indent
			
			for function_name in "${FUNCTIONS_TO_TEST[@]}"; do
				shpm_log "$function_name ... NO TEST FOUND!" "red"
			done
			
			decrease_g_indent 
			decrease_g_indent
			decrease_g_indent
		fi
		
		if [ "$FILE_FUNCTIONS_COUNT" -gt 0 ]; then 
			PERCENT_COVERAGE=$(bc <<< "scale=2; $FILE_FUNCTIONS_WITH_TEST_COUNT / $FILE_FUNCTIONS_COUNT * 100")
		else
			PERCENT_COVERAGE=0
		fi
		
		shpm_log ""
		shpm_log "Found $FILE_FUNCTIONS_COUNT function(s) in $filename. $FILE_FUNCTIONS_WITH_TEST_COUNT function(s) have tests."
		shpm_log "Coverage in $filename: $PERCENT_COVERAGE"
		shpm_log "FILE: $filename - Analysis End"
	
		decrease_g_indent
		
		shpm_log "$FILES_ANALYSIS_LOG_SEPARATOR"
	done
	
	if [ $TOTAL_FUNCTIONS_WITH_TEST_COUNT -gt 0 ]; then 
		TOTAL_COVERAGE=$(bc <<< "scale=2; $TOTAL_FUNCTIONS_WITH_TEST_COUNT / $TOTAL_FUNCTIONS_FOUNDED_COUNT * 100")
	else
		TOTAL_COVERAGE=0
	fi
	
	shpm_log ""
	shpm_log "Finish test coverage analysis in $SRC_DIR_PATH:"
	shpm_log ""
	shpm_log "Found $TOTAL_FUNCTIONS_FOUNDED_COUNT function(s) in $TOTAL_FILES_ANALYSED_COUNT file(s) analysed. $TOTAL_FUNCTIONS_WITH_TEST_COUNT function(s) have tests."
	shpm_log ""
	
	shpm_log "Total Coverage in %:"
	SHPM_LOG_DISABLED="$FALSE"
	
	echo "$TOTAL_COVERAGE" # this is a "return" value for this function	
}
