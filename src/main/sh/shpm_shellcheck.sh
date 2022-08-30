run_shellcheck() {
    local shellcheck_cmd
    local shellcheck_log_filename
    local gedit_cmd
    
    shellcheck_cmd=$(which shellcheck)
    shellcheck_log_filename="shellcheck.log"
    
    gedit_cmd=$(which gedit)

	shpm_log_operation "Running ShellCheck in .sh files ..."
    
    if [[ "$SKIP_SHELLCHECK" == "true" ]]; then
    	shpm_log ""
    	shpm_log "WARNING: Skipping ShellCheck verification !!!"
    	shpm_log ""
    	return "$TRUE" # continue execution with warning    	
    fi
    
    if [[ ! -z "$shellcheck_cmd" ]]; then
	    
	    create_path_if_not_exists "$TARGET_DIR_PATH"
	    
	    for FILE_TO_CHECK in $SRC_DIR_PATH/*.sh; do        
	    
	    	if "$shellcheck_cmd" -x -e SC1090 -e SC1091 "$FILE_TO_CHECK" > "$TARGET_DIR_PATH/$shellcheck_log_filename"; then	    	
	    		shpm_log "$FILE_TO_CHECK passed in shellcheck" "green"
	    	else
	    		shpm_log "FAIL!" "red"
	    		shpm_log "$FILE_TO_CHECK have shellcheck errors." "red"
	    		shpm_log "See log in $TARGET_DIR_PATH/$shellcheck_log_filename" "red"
	    		
	    		sed -i '1s/^/=== ERRORS FOUND BY ShellCheck tool: === /' "$TARGET_DIR_PATH/$shellcheck_log_filename"
	    		
	    		if [[ "$gedit_cmd" != "" ]]; then
	    			shpm_log "Open $TARGET_DIR_PATH/$shellcheck_log_filename ..."
	    			"$gedit_cmd" "$TARGET_DIR_PATH/$shellcheck_log_filename"
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
