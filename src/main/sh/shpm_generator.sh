run_init_project_structure() {

	shpm_log_operation "Running sh-pm init ..."
	
	local FILENAME
	FILENAME="/tmp/nothing"
	
	create_path_if_not_exists "$SRC_DIR_PATH"

	create_path_if_not_exists "$TEST_DIR_PATH"
	    
    cd "$ROOT_DIR_PATH" || exit 1
    
    shpm_log "Move source code to $SRC_DIR_PATH ..."
    for file in "$ROOT_DIR_PATH"/*
	do
        FILENAME=$( basename "$file" )
        
        if [[  "$FILENAME" != "."* && "$FILENAME" != *"*"* && "$FILENAME" != *"~"* && "$FILENAME" != *"\$"* ]]; then
		    if [[ -f $file ]]; then
		        if [[ "$FILENAME" != "bootstrap.sh" && "$FILENAME" != "pom.sh" && "$FILENAME" != "shpm.sh" && "$FILENAME" == *".sh" ]]; then
		            shpm_log " - Moving file $file to $SRC_DIR_PATH ..."
		            mv "$file" "$SRC_DIR_PATH"
		        else
		        	shpm_log " - Skipping $file"
		        fi
		    fi
		    if [[ -d $file ]]; then
		        if [[ "$FILENAME" != "src" && "$FILENAME" != "target" && "$FILENAME" != "tmpoldshpm" ]]; then
	   	            shpm_log " - Moving folder $file to $SRC_DIR_PATH ..."
	   	            mv "$file" "$SRC_DIR_PATH"
	   	        else
	   	        	shpm_log " - Skipping $file"	            
		        fi
		    fi
		else
		    shpm_log " - Skipping $file"
	    fi
	done
	
	cd "$SRC_DIR_PATH" || exit 1 
	
	shpm_log "sh-pm expected project structure initialized"
	exit 0
}
