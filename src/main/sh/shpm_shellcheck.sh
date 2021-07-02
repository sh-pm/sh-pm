run_shellcheck() {
    local SHELLCHECK_CMD
    local SHELLCHECK_LOG_FILENAME
    local GEDIT_CMD
    
    SHELLCHECK_CMD=$(which shellcheck)
    SHELLCHECK_LOG_FILENAME="shellcheck.log"
    
    GEDIT_CMD=$(which gedit)

	shpm_log_operation "Running ShellCheck in .sh files ..."
    
    if [[ "$SKIP_SHELLCHECK" == "true" ]]; then
    	shpm_log ""
    	shpm_log "WARNING: Skipping ShellCheck verification !!!"
    	shpm_log ""
    	return "$TRUE" # continue execution with warning    	
    fi
    
    if [[ ! -z "$SHELLCHECK_CMD" ]]; then
	    
	    create_path_if_not_exists "$TARGET_DIR_PATH"
	    
	    for FILE_TO_CHECK in $SRC_DIR_PATH/*.sh; do        
	    
	    	if "$SHELLCHECK_CMD" -x -e SC1090 -e SC1091 "$FILE_TO_CHECK" > "$TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME"; then	    	
	    		shpm_log "$FILE_TO_CHECK passed in shellcheck" "green"
	    	else
	    		shpm_log "FAIL!" "red"
	    		shpm_log "$FILE_TO_CHECK have shellcheck errors." "red"
	    		shpm_log "See log in $TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME" "red"
	    		
	    		sed -i '1s/^/=== ERRORS FOUND BY ShellCheck tool: === /' "$TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME"
	    		
	    		if [[ "$GEDIT_CMD" != "" ]]; then
	    			shpm_log "Open $TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME ..."
	    			"$GEDIT_CMD" "$TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME"
	    		fi
	    		
	    		exit 1
	    	fi
    	done;
    else
    	shpm_log "WARNING: ShellCheck not found: skipping ShellCheck verification !!!" "yellow"
    fi
    
    shpm_log ""
    shpm_log "ShellCheck finish."
    shpm_log ""
}
