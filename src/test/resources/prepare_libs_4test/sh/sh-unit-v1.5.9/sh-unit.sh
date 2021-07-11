######## sh_unit_util.sh ######################################################################################################################
string_start_with(){
	local STRING=$1
	local SUBSTRING=$2
	
	if [[ $STRING == "$SUBSTRING"* ]]; then
		return "$TRUE";
	else
		return "$FALSE";
	fi
}
array_contain_element() {
	local -n P_ARRAY="$1"
	local ELEMENT="$2"
	
	for iter in ${P_ARRAY[@]}; do
		if [[ "$iter" == "$ELEMENT" ]]; then
			return "$TRUE"
		fi	
	done
	
	return "$FALSE"
}
######## asserts.sh ###########################################################################################################################
get_caller_info(){
	echo "$( basename "${BASH_SOURCE[2]}" ) (l. ${BASH_LINENO[1]})"
}
assert_equals(){
	
	local ASSERT_DESCRIPTION="$3"
	
	export ASSERTIONS_TOTAL_COUNT=$((ASSERTIONS_TOTAL_COUNT+1))
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=$((TESTCASE_ASSERTIONS_TOTAL_COUNT+1))
	if [[ "$1" == "$2" ]]; then
	
		echo -e "$( get_caller_info ): ${ECHO_COLOR_GREEN}Assert Success! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
		
		export ASSERTIONS_SUCCESS_COUNT=$((ASSERTIONS_SUCCESS_COUNT+1))
		export TESTCASE_ASSERTIONS_SUCCESS_COUNT=$((TESTCASE_ASSERTIONS_SUCCESS_COUNT+1))
		
		return "$TRUE"
		
	else
		echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"		
		echo -e "${ECHO_COLOR_RED}     ${FUNCNAME[0]}: |$1| is NOT EQUALs |$2|${ECHO_COLOR_NC}"
		export ASSERTIONS_FAIL_COUNT=$((ASSERTIONS_FAIL_COUNT+1))		 
		export TESTCASE_ASSERTIONS_FAIL_COUNT=$((TESTCASE_ASSERTIONS_FAIL_COUNT+1))
		 
		TEST_EXECUTION_STATUS="$STATUS_ERROR"
		LAST_TESTCASE_EXECUTION_STATUS="$STATUS_ERROR"
		
		return "$FALSE"
	fi
}
assert_contains(){
	
	local ASSERT_DESCRIPTION="$3"
	
	export ASSERTIONS_TOTAL_COUNT=$((ASSERTIONS_TOTAL_COUNT+1))
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=$((TESTCASE_ASSERTIONS_TOTAL_COUNT+1))
	if [[ "$1" == *"$2"* ]]; then
	
		echo -e "$( get_caller_info ): ${ECHO_COLOR_GREEN}Assert Success! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
		
		export ASSERTIONS_SUCCESS_COUNT=$((ASSERTIONS_SUCCESS_COUNT+1))
		export TESTCASE_ASSERTIONS_SUCCESS_COUNT=$((TESTCASE_ASSERTIONS_SUCCESS_COUNT+1))
		
		return "$TRUE"
		
	else
		echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"		
		echo -e "${ECHO_COLOR_RED}     ${FUNCNAME[0]}: |$1| NOT contains |$2|${ECHO_COLOR_NC}"
		export ASSERTIONS_FAIL_COUNT=$((ASSERTIONS_FAIL_COUNT+1))		 
		export TESTCASE_ASSERTIONS_FAIL_COUNT=$((TESTCASE_ASSERTIONS_FAIL_COUNT+1))
		 
		TEST_EXECUTION_STATUS="$STATUS_ERROR"
		LAST_TESTCASE_EXECUTION_STATUS="$STATUS_ERROR"
		
		return "$FALSE"
	fi
}
assert_start_with(){
	
	local ASSERT_DESCRIPTION="$3"
	
	export ASSERTIONS_TOTAL_COUNT=$((ASSERTIONS_TOTAL_COUNT+1))
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=$((TESTCASE_ASSERTIONS_TOTAL_COUNT+1))
	
	if [[ ! -z "$1" && ! -z "$2" && "$1" =~ ^"$2".* ]]; then
	
		echo -e "$( get_caller_info ): ${ECHO_COLOR_GREEN}Assert Success! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
		
		export ASSERTIONS_SUCCESS_COUNT=$((ASSERTIONS_SUCCESS_COUNT+1))
		export TESTCASE_ASSERTIONS_SUCCESS_COUNT=$((TESTCASE_ASSERTIONS_SUCCESS_COUNT+1))
		
		return "$TRUE"
	else
		echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
				
		if [[ -z "$1" || -z "$2" ]]; then 
			echo -e "${ECHO_COLOR_RED}     ${FUNCNAME[0]}: Receive empty param(s): 1->|$1|, 2->|$2|${ECHO_COLOR_NC}"		
		else
			echo -e "${ECHO_COLOR_RED}     ${FUNCNAME[0]}: |$1| NOT start with |$2|${ECHO_COLOR_NC}"		
		fi
	
		export ASSERTIONS_FAIL_COUNT=$((ASSERTIONS_FAIL_COUNT+1))		 
		export TESTCASE_ASSERTIONS_FAIL_COUNT=$((TESTCASE_ASSERTIONS_FAIL_COUNT+1))
		 
		TEST_EXECUTION_STATUS="$STATUS_ERROR"
		LAST_TESTCASE_EXECUTION_STATUS="$STATUS_ERROR"
		
		return "$FALSE"
	fi
}
assert_end_with(){
	
	local ASSERT_DESCRIPTION="$3"
	
	export ASSERTIONS_TOTAL_COUNT=$((ASSERTIONS_TOTAL_COUNT+1))
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=$((TESTCASE_ASSERTIONS_TOTAL_COUNT+1))
	
	if [[ ! -z "$1" && ! -z "$2" && "$1" =~ .*"$2"$ ]]; then
	
		echo -e "$( get_caller_info ): ${ECHO_COLOR_GREEN}Assert Success! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
		
		export ASSERTIONS_SUCCESS_COUNT=$((ASSERTIONS_SUCCESS_COUNT+1))
		export TESTCASE_ASSERTIONS_SUCCESS_COUNT=$((TESTCASE_ASSERTIONS_SUCCESS_COUNT+1))
		
		return "$TRUE"
	else
		echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
				
		if [[ -z "$1" || -z "$2" ]]; then 
			echo -e "${ECHO_COLOR_RED}     ${FUNCNAME[0]}: Receive empty param(s): 1->|$1|, 2->|$2|${ECHO_COLOR_NC}"		
		else
			echo -e "${ECHO_COLOR_RED}     ${FUNCNAME[0]}: |$1| NOT end with |$2|${ECHO_COLOR_NC}"		
		fi
	
		export ASSERTIONS_FAIL_COUNT=$((ASSERTIONS_FAIL_COUNT+1))		 
		export TESTCASE_ASSERTIONS_FAIL_COUNT=$((TESTCASE_ASSERTIONS_FAIL_COUNT+1))
		 
		TEST_EXECUTION_STATUS="$STATUS_ERROR"
		LAST_TESTCASE_EXECUTION_STATUS="$STATUS_ERROR"
		
		return "$FALSE"
	fi
}
assert_true(){
    local VALUE="$1"
    local ASSERT_DESCRIPTION="$2"
    
    export ASSERTIONS_TOTAL_COUNT=$((ASSERTIONS_TOTAL_COUNT+1))
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=$((TESTCASE_ASSERTIONS_TOTAL_COUNT+1))
    
    if [[ -z "$VALUE" ]]; then
		LAST_FUNCTION_STATUS_EXECUTION="$?"
		VALUE=$LAST_FUNCTION_STATUS_EXECUTION
    fi
	if [[ "$VALUE" == "$TRUE" ]]; then
		echo -e "$( get_caller_info ): ${ECHO_COLOR_GREEN}Assert Success! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
		
		export ASSERTIONS_SUCCESS_COUNT=$((ASSERTIONS_SUCCESS_COUNT+1))
		export TESTCASE_ASSERTIONS_SUCCESS_COUNT=$((TESTCASE_ASSERTIONS_SUCCESS_COUNT+1))
		
		return "$TRUE";
	else
    	echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
		echo -e "${ECHO_COLOR_RED}     ${FUNCNAME[0]}: |$VALUE| is NOT true${ECHO_COLOR_NC}"
		
		export ASSERTIONS_FAIL_COUNT=$((ASSERTIONS_FAIL_COUNT+1))
		export TESTCASE_ASSERTIONS_FAIL_COUNT=$((TESTCASE_ASSERTIONS_FAIL_COUNT+1))
		
		TEST_EXECUTION_STATUS="$STATUS_ERROR"
		LAST_TESTCASE_EXECUTION_STATUS="$STATUS_ERROR"
		
		return "$FALSE";
	fi
}	
assert_false(){
	local VALUE="$1"
    local ASSERT_DESCRIPTION="$2"
    
    export ASSERTIONS_TOTAL_COUNT=$((ASSERTIONS_TOTAL_COUNT+1))
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=$((TESTCASE_ASSERTIONS_TOTAL_COUNT+1))
    
    if [[ -z $VALUE ]]; then
		LAST_FUNCTION_STATUS_EXECUTION="$?"
		VALUE=$LAST_FUNCTION_STATUS_EXECUTION
    fi
	if [[ $VALUE == "$TRUE" ]]; then
    	echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
	    
	    echo -e "${ECHO_COLOR_RED}     ${FUNCNAME[0]}: |$VALUE| is NOT false${ECHO_COLOR_NC}"
	    
	    export ASSERTIONS_FAIL_COUNT=$((ASSERTIONS_FAIL_COUNT+1))
	    export TESTCASE_ASSERTIONS_FAIL_COUNT=$((TESTCASE_ASSERTIONS_FAIL_COUNT+1))
	    
		TEST_EXECUTION_STATUS="$STATUS_ERROR"
		LAST_TESTCASE_EXECUTION_STATUS="$STATUS_ERROR"
		
		return "$FALSE";
	else
		echo -e "$( get_caller_info ): ${ECHO_COLOR_GREEN}Assert Success! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
		
		export ASSERTIONS_SUCCESS_COUNT=$((ASSERTIONS_SUCCESS_COUNT+1))
		export TESTCASE_ASSERTIONS_SUCCESS_COUNT=$((TESTCASE_ASSERTIONS_SUCCESS_COUNT+1))
		
		return "$TRUE";
	fi
}
assert_fail(){
	local ASSERT_DESCRIPTION="$1"
	export ASSERTIONS_TOTAL_COUNT=$((ASSERTIONS_TOTAL_COUNT+1))
	export ASSERTIONS_FAIL_COUNT=$((ASSERTIONS_FAIL_COUNT+1))
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=$((TESTCASE_ASSERTIONS_TOTAL_COUNT+1))
	export TESTCASE_ASSERTIONS_FAIL_COUNT=$((TESTCASE_ASSERTIONS_FAIL_COUNT+1))
	echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
    
	TEST_EXECUTION_STATUS="$STATUS_ERROR"
	LAST_TESTCASE_EXECUTION_STATUS="$STATUS_ERROR"
	
	return "$FALSE"
}
assert_success(){
	local ASSERT_DESCRIPTION="$1"
	export ASSERTIONS_TOTAL_COUNT=$((ASSERTIONS_TOTAL_COUNT+1))
	export ASSERTIONS_SUCCESS_COUNT=$((ASSERTIONS_SUCCESS_COUNT+1))
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=$((TESTCASE_ASSERTIONS_TOTAL_COUNT+1))
	export TESTCASE_ASSERTIONS_SUCCESS_COUNT=$((TESTCASE_ASSERTIONS_SUCCESS_COUNT+1))
    echo -e "$( get_caller_info ): ${ECHO_COLOR_GREEN}Assert Success! $ASSERT_DESCRIPTION${ECHO_COLOR_NC}"
    
    return "$TRUE"	
}
assert_array_contains() {
	local -n P_ARRAY=$1
	local ITEM=$2
	
	for array_item in ${P_ARRAY[@]}; do
		if [[ "$array_item" == "$ITEM" ]]; then
			return "$TRUE";
		fi
	done 
	
	echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! Expect value |$ITEM| in array, but it NOT found: (${ECHO_COLOR_NC}"
	sh_unit_print_array_for_msg_error P_ARRAY
	
	return "$FALSE"
}
assert_array_not_contains() {
	local -n P_ARRAY=$1
	local ITEM=$2
	
	for array_item in ${P_ARRAY[@]}; do
		if [[ "$array_item" == "$ITEM" ]]; then
			
			echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! Expect value |$ITEM| not in array, but it was found: (${ECHO_COLOR_NC}"
			sh_unit_print_array_for_msg_error P_ARRAY
			
			return "$FALSE";
		fi
	done 
	
	return "$TRUE"
}
assert_array_contains_values() {
	local -n P_ARRAY
	local -n P_VALUES
	local ITEM_FOUND
	
	P_ARRAY=$1
	P_VALUES=$2
	
	for expected_item in ${P_VALUES[@]}; do
		ITEM_FOUND="$FALSE"
		
		for array_item in ${P_ARRAY[@]}; do
		
			if [[ "$array_item" == "$expected_item" ]]; then
				ITEM_FOUND="$TRUE"
			fi
		done
		
		if [[ "$ITEM_FOUND" != "$TRUE" ]]; then
			echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! Expect item |$expected_item| not found in array: (${ECHO_COLOR_NC}"
			sh_unit_print_array_for_msg_error P_ARRAY
		
			return "$FALSE"
		fi
	done
	return "$TRUE"	
}
assert_array_contains_only_this_values() {
	local -n P_ARRAY
	local -n P_VALUES
	
	local ITEM_FOUND
	
	P_ARRAY="$1"
	P_VALUES="$2"
	
	if [[ "${#P_ARRAY[@]}" != "${#P_VALUES[@]}" ]]; then
		echo -e "Arrays have diferent sizes! "
		echo -e "Array of values have size = ${#P_ARRAY[@]}"
		sh_unit_print_array_for_msg_error P_ARRAY
		
	 	echo -e "Array of EXPECTED values have size = ${#P_VALUES[@]}"
	 	sh_unit_print_array_for_msg_error P_VALUES
	 	
		return "$FALSE"
	fi
	
	for expected_item in ${P_VALUES[@]}; do
		ITEM_FOUND="$FALSE"
		
		for array_item in ${P_ARRAY[@]}; do
		
			if [[ "$array_item" == "$expected_item" ]]; then
				ITEM_FOUND="$TRUE"
			fi
		done
		
		if [[ "$ITEM_FOUND" != "$TRUE" ]]; then
			echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! Expect item |$expected_item| not found in array: ${ECHO_COLOR_NC}"
		
			return "$FALSE"
		fi
	done
	
	
	for array_item in ${P_ARRAY[@]}; do
		ITEM_FOUND="$FALSE"
		
		for expected_item in ${P_VALUES[@]}; do		
			if [[ "$array_item" == "$expected_item" ]]; then
				ITEM_FOUND="$TRUE"
			fi
		done
		
		if [[ "$ITEM_FOUND" != "$TRUE" ]]; then
			echo -e "$( get_caller_info ): ${ECHO_COLOR_RED}Assert FAIL! Array contain a unexpected item |$array_item|${ECHO_COLOR_NC}"
			sh_unit_print_array_for_msg_error P_ARRAY
		
			return "$FALSE"
		fi
	done
	return "$TRUE"	
}
######## sh_unit_g_vars.sh ####################################################################################################################
define_sh_unit_global_variables() {
	if [[ -z "$SH_UNIT_GLOBAL_VARS_ALREADY_DEFINED" || "$SH_UNIT_GLOBAL_VARS_ALREADY_DEFINED" == "$FALSE" ]]; then
	
		export TEST_FUNCTION_PREFIX="test_"
		export TEST_FILENAME_SUFIX="_test.sh"
		
		export STATUS_SUCCESS="$TRUE"
		export STATUS_ERROR="$FALSE"
		
		reset_g_test_execution_status
		
		reset_g_test_counters
		
		export SH_UNIT_GLOBAL_VARS_ALREADY_DEFINED="$TRUE"
	fi
}
reset_g_test_execution_status() {
	export TEST_EXECUTION_STATUS="$STATUS_SUCCESS"
	export LAST_TESTCASE_EXECUTION_STATUS="$STATUS_SUCCESS"
}
reset_g_test_counters() {
	export TESTCASE_TOTAL_COUNT=0
	export TESTCASE_FAIL_COUNT=0
	export TESTCASE_SUCCESS_COUNT=0
	
	export ASSERTIONS_TOTAL_COUNT=0
	export ASSERTIONS_FAIL_COUNT=0
	export ASSERTIONS_SUCCESS_COUNT=0
	
	reset_testcase_counters
}
reset_testcase_counters() {
	export TESTCASE_ASSERTIONS_TOTAL_COUNT=0
	export TESTCASE_ASSERTIONS_FAIL_COUNT=0
	export TESTCASE_ASSERTIONS_SUCCESS_COUNT=0
}
define_sh_unit_global_variables
######## test_runner.sh #######################################################################################################################
display_statistics() {
	echo ""
	echo "(*) ASSERTIONS executed in $SCRIPT_NAME_TO_RUN_TESTS: "
	echo "    - Total:   $ASSERTIONS_TOTAL_COUNT"
	echo "    - Success: $ASSERTIONS_SUCCESS_COUNT"
	echo "    - Fail:    $ASSERTIONS_FAIL_COUNT"
	echo ""
	echo "(*) TEST CASES executed in $SCRIPT_NAME_TO_RUN_TESTS: "
	echo "    - Total:   $TESTCASE_TOTAL_COUNT"
	echo "    - Success: $TESTCASE_SUCCESS_COUNT"
	echo "    - Fail:    $TESTCASE_FAIL_COUNT"
	echo ""
}
display_final_result() {
	echo "(*) FINAL RESULT of execution:"	
	if [[ "$TEST_EXECUTION_STATUS" != "$STATUS_SUCCESS" ]]; then 
		echo -e "      ${ECHO_COLOR_RED}FAIL!!!${ECHO_COLOR_NC}"
	else		
		echo -e "      ${ECHO_COLOR_GREEN}OK${ECHO_COLOR_NC}"
	fi
	echo ""
}
display_finish_execution() {
	echo ""
	echo "-------------------------------------------------------------"
	echo "Finish execution"
}
display_testcase_execution_statistics() {
	echo "  Assertions executed in $FUNCTION_NAME: "
	echo "   - Success: $TESTCASE_ASSERTIONS_SUCCESS_COUNT"
	echo "   - Fail:    $TESTCASE_ASSERTIONS_FAIL_COUNT"
	echo "   - Total:   $TESTCASE_ASSERTIONS_TOTAL_COUNT"
}
display_finish_execution_of_files() {
  	echo -e "\n########################################################################################################"
	echo -e "\nFinish execution of files\n"
}
update_testcase_counters() {
	if [[ "$LAST_TESTCASE_EXECUTION_STATUS" == "$STATUS_OK" ]]; then
		export TESTCASE_SUCCESS_COUNT=$((TESTCASE_SUCCESS_COUNT+1))
	else
		export TESTCASE_FAIL_COUNT=$((TESTCASE_FAIL_COUNT+1))
	fi
	
	export TESTCASE_TOTAL_COUNT=$((TESTCASE_TOTAL_COUNT+1))
}
display_testcase_execution_start() {
	local FUNCTION_NAME
	
	FUNCTION_NAME="$1"
	
	echo ""
	echo "---[ $FUNCTION_NAME ]----------------------------------------------------------"
	echo ""
}
display_test_file_delimiter() {
	echo -e "\n########################### $( basename "$1" ) ######################################################\n"
}
display_file_execution_start() {
	display_test_file_delimiter $1
	echo "Location: $1"
    echo "Start execution of test case(s)  ..."
}
get_all_function_names_from_file() {
	local SCRIPT_NAME_TO_RUN_TESTS
	
	SCRIPT_NAME_TO_RUN_TESTS="$1"
	
	grep -E '^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)' "$SCRIPT_NAME_TO_RUN_TESTS" | tr \(\)\}\{ ' ' | sed 's/^[ \t]*//;s/[ \t]*$//'
}
get_all_test_function_names_from_file() {
	local SCRIPT_NAME_TO_RUN_TESTS
	
	SCRIPT_NAME_TO_RUN_TESTS="$1"
	
	grep -E '^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)' "$SCRIPT_NAME_TO_RUN_TESTS" | grep -E '^test_*' | tr \(\)\}\{ ' ' | sed 's/^[ \t]*//;s/[ \t]*$//'
}
run_testcases_in_files() {
	local -n P_ALL_TEST_FILES
  	local -n P_TEST_FILTERS
  	
  	local FUNCTIONS_TO_RUN
  	local FILE
	
	P_ALL_TEST_FILES="$1"
  	P_TEST_FILTERS="$2"
  	
  	# Run WITH filters
  	if (( "${#P_TEST_FILTERS[@]}" > 0 )); then
	  	for test_filter in ${P_TEST_FILTERS[@]}; do
	  		if [[ "$test_filter" == *"="* ]]; then
	  			FILE=${test_filter%=*}
				FUNCTIONS_TO_RUN_STR=${test_filter#*=}
				
				if [[ ! -z "$FUNCTIONS_TO_RUN_STR" ]]; then
					if [[ "$FUNCTIONS_TO_RUN_STR" == *","* ]]; then
						IFS=',' read -r -a FUNCTIONS_TO_RUN <<< "$FUNCTIONS_TO_RUN_STR"
					else
						FUNCTIONS_TO_RUN=( "$FUNCTIONS_TO_RUN_STR" ) 	
					fi
				fi
			else
				FILE=${test_filter}				
				FUNCTIONS_TO_RUN=( )
	  		fi
	  		
			for file in "${P_ALL_TEST_FILES[@]}"; do
				if [[ $( basename "$file" ) == "$FILE" ]]; then
					run_testcases_in_file "$file" FUNCTIONS_TO_RUN					
				fi
			done
	  	done
  	# Run WITHOUT filters	  	
	else
		FUNCTIONS_TO_RUN=( $( get_all_test_function_names_from_file ) )
		if (( "${#P_ALL_TEST_FILES[@]}" > 0 )); then
			for file in "${P_ALL_TEST_FILES[@]}"
			do
				run_testcases_in_file "$file" FUNCTIONS_TO_RUN
			done
		else
			echo "No test files found!"
		fi
  	fi
  	
	display_finish_execution_of_files
}
run_testcases_in_file() {
	local SCRIPT_NAME_TO_RUN_TESTS
	local -n P_FUNCTIONS_TO_RUN
	
	SCRIPT_NAME_TO_RUN_TESTS="$1"
	P_FUNCTIONS_TO_RUN="$2"
	
    display_file_execution_start "$SCRIPT_NAME_TO_RUN_TESTS"
     
	source "$SCRIPT_NAME_TO_RUN_TESTS"
    TEST_FUNCTIONS_IN_FILE=( $( get_all_test_function_names_from_file "$SCRIPT_NAME_TO_RUN_TESTS" ) );    
	
	for FUNCTION_NAME in "${TEST_FUNCTIONS_IN_FILE[@]}"
	do
		if (( ${#P_FUNCTIONS_TO_RUN[@]} > 0 )); then
		 	if ( array_contain_element P_FUNCTIONS_TO_RUN "$FUNCTION_NAME" ); then		 			
				run_test_case "$FUNCTION_NAME"
			fi
		else
			run_test_case "$FUNCTION_NAME"
		fi
	done
	
	display_finish_execution
	
	display_statistics
	
	display_final_result
	
	if [[ "$TEST_EXECUTION_STATUS" == "$STATUS_OK" ]]; then
		return "$TRUE";
	else		
		return "$FALSE";
	fi
}
run_test_case() {
	local TESTCASE_NAME
	
	TESTCASE_NAME="$1"
	display_testcase_execution_start "$TESTCASE_NAME"
			
	LAST_TESTCASE_EXECUTION_STATUS="$STATUS_OK"
	
	reset_testcase_counters
	
	$TESTCASE_NAME # this line call/execute a test function!
	
	display_testcase_execution_statistics
	
	update_testcase_counters
}