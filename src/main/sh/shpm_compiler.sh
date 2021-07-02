get_entry_point_file() {
	
	if [[ -z "$MANIFEST_P_ENTRY_POINT_FILE" ]]; then
		return "$FALSE"
	fi
	
	if [[ -z "$MANIFEST_FILE_PATH" ]]; then
		return "$FALSE"
	fi
	
	echo $( grep "$MANIFEST_P_ENTRY_POINT_FILE" "$MANIFEST_FILE_PATH" | cut -d '=' -f 2 )
	
	return "$TRUE"
}

get_compiled_filename() {
	echo "$( basename "$ROOT_DIR_PATH" )"".sh"
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

run_compile_sh_project() {
	
	shpm_log_operation "Compile"
		
	if [[ ! -f "$MANIFEST_FILE_PATH" ]]; then
		shpm_log "\nERROR: $MANIFEST_FILE_PATH not found!\n" "red"
		return $FALSE
	fi
	
	local FILE_ENTRY_POINT
	
	local FILE_WITH_CAT_SH_LIBS
	local FILE_WITH_CAT_SH_SRCS
	local FILE_WITH_SEPARATOR
	local FILE_WITH_BOOTSTRAP_SANITIZED
	local COMPILED_FILE_NAME
	local COMPILED_FILE_PATH
	
	local INCLUDE_LIB_AND_FILE
	local SHEBANG_FIRST_LINE
	local PATTERN_INCLUDE_BOOTSTRAP_FILE_1
	local PATTERN_INCLUDE_BOOTSTRAP_FILE_2
	local PATTERN_INCLUDE_BOOTSTRAP_FILE
	
	local SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_1
	local SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_2
	local SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE
	
	FILE_ENTRY_POINT=$( get_entry_point_file )
	
	if [[ -z "$FILE_ENTRY_POINT" ]]; then
		shpm_log ""
		shpm_log "ERROR: Inform \"$MANIFEST_P_ENTRY_POINT_FILE\" propertie value in file: $MANIFEST_FILE_PATH!" "red"
		shpm_log ""
		shpm_log "Exemple content of $MANIFEST_FILENAME file:"
		shpm_log ""
		shpm_log "$MANIFEST_P_ENTRY_POINT_FILE""=""foo.sh"
		shpm_log "$MANIFEST_P_ENTRY_POINT_FUNCTION""=""main"
		shpm_log ""
		
		return $FALSE
	fi
	
	FILE_WITH_CAT_SH_LIBS="$TMP_DIR_PATH/lib_files_concat"
	FILE_WITH_CAT_SH_SRCS="$TMP_DIR_PATH/sh_files_concat"
	FILE_WITH_SEPARATOR="$TMP_DIR_PATH/separator"
	FILE_WITH_BOOTSTRAP_SANITIZED="$TMP_DIR_PATH/$BOOTSTRAP_FILENAME"
	
   	create_path_if_not_exists "$TARGET_DIR_PATH"
   
   	COMPILED_FILE_NAME=$( get_compiled_filename ) 
	
	COMPILED_FILE_PATH="$TARGET_DIR_PATH/$COMPILED_FILE_NAME"
	
	INCLUDE_LIB_AND_FILE="include_lib\|include_file"
	SHEBANG_FIRST_LINE="#!/bin/bash\|#!/usr/bin/env bash"
	
	PATTERN_INCLUDE_BOOTSTRAP_FILE_1="source ./$BOOTSTRAP_FILENAME"
	PATTERN_INCLUDE_BOOTSTRAP_FILE_2="source ../../../$BOOTSTRAP_FILENAME"
	PATTERN_INCLUDE_BOOTSTRAP_FILE="$PATTERN_INCLUDE_BOOTSTRAP_FILE_1\|$PATTERN_INCLUDE_BOOTSTRAP_FILE_2"
	
	SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_1='source "$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME"'
	SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_2='source "$ROOT_DIR_PATH/'$DEPENDENCIES_FILENAME'"'
	SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE="$SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_1\|$SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_2"
	
	local FILE_SEPARATOR="#####################################################################################################################################";	
	
	shpm_log ""	
	shpm_log "Running compile pipeline:"
	shpm_log "" 

   	shpm_log "- Prepare libraries:"
   	increase_g_indent
   	shpm_log "- Ensure \\\n in end of lib files to prevent file concatenation errors ..."
	find "$LIB_DIR_PATH"  -type f ! -name "$DEPENDENCIES_FILENAME" ! -name 'sh-pm*' -name '*.sh' -exec sed -i -e '$a\' {} \;
	                      
	shpm_log "- Concat all .sh lib files that will be used in compile ..."		
	local LIB_FILES=$( find "$LIB_DIR_PATH"  -type f ! -name "$DEPENDENCIES_FILENAME" ! -name 'sh-pm*' -name '*.sh' )
	for file in ${LIB_FILES[@]}; do
		echo "### $file ${FILE_SEPARATOR:0:-${#file}}" > "$FILE_WITH_SEPARATOR"
		cat "$FILE_WITH_SEPARATOR" "$file" >> "$FILE_WITH_CAT_SH_LIBS""_tmp"
	done

	shpm_log "- Remove problematic lines in all .sh lib files ..."
	grep -v "$PATTERN_INCLUDE_BOOTSTRAP_FILE" < "$FILE_WITH_CAT_SH_LIBS""_tmp" | grep -v "$SHEBANG_FIRST_LINE" | grep -v "$INCLUDE_LIB_AND_FILE" > "$FILE_WITH_CAT_SH_LIBS"
	remove_file_if_exists "$FILE_WITH_CAT_SH_LIBS""_tmp"
   	decrease_g_indent

   	shpm_log "- Prepare source code:"
   	increase_g_indent
   	shpm_log "- Ensure \\\n in end of src files to prevent file concatenation errors ..."
	find "$SRC_DIR_PATH"  -type f ! -path "sh-pm*" ! -name "$DEPENDENCIES_FILENAME" -name '*.sh' -exec sed -i -e '$a\' {} \;
	
	shpm_log "- Concat all .sh src files that will be used in compile except entrypoint file ..."
	
	local SRC_FILES=$( find "$SRC_DIR_PATH"  -type f ! -path "sh-pm*" ! -name "pom.sh" -name '*.sh' )
	local FILE_ENTRYPOINT_PATH=""
	
	for file in ${SRC_FILES[@]}; do
		if [[ "$FILE_ENTRY_POINT" == "$( basename "$file" )" ]]; then
			FILE_ENTRYPOINT_PATH="$file"
		else			
			echo "### $file ${FILE_SEPARATOR:0:-${#file}}" > "$FILE_WITH_SEPARATOR"
			cat "$FILE_WITH_SEPARATOR" "$file" >> "$FILE_WITH_CAT_SH_SRCS""_tmp"
		fi 		
	done
	
	
	shpm_log "- Remove problematic lines in all .sh src files ..."
	grep -v "$PATTERN_INCLUDE_BOOTSTRAP_FILE" < "$FILE_WITH_CAT_SH_SRCS""_tmp" | grep -v "$SHEBANG_FIRST_LINE" | grep -v "$INCLUDE_LIB_AND_FILE" > "$FILE_WITH_CAT_SH_SRCS"
	remove_file_if_exists "$FILE_WITH_CAT_SH_SRCS""_tmp"

	shpm_log "- Remove problematic lines in $ROOT_DIR_PATH/$BOOTSTRAP_FILENAME file ..."
	grep -v "$SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE" < "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" | grep -v "$SHEBANG_FIRST_LINE" > "$FILE_WITH_BOOTSTRAP_SANITIZED"  
   	decrease_g_indent

	remove_file_if_exists "$COMPILED_FILE_PATH"
	
	shpm_log "- Generate compiled file ..."
	
	local DEP_FILE_PATH="$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME";
	echo "### $DEP_FILE_PATH ${FILE_SEPARATOR:0:-${#DEP_FILE_PATH}}" > "$FILE_WITH_SEPARATOR""_dep"
	
	local BOOTSTRAP_FILE_PATH="$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME";
	echo "### $BOOTSTRAP_FILE_PATH ${FILE_SEPARATOR:0:-${#BOOTSTRAP_FILE_PATH}}" > "$FILE_WITH_SEPARATOR""_bootstrap"
		
	echo "### $FILE_ENTRYPOINT_PATH ${FILE_SEPARATOR:0:-${#FILE_ENTRYPOINT_PATH}}" > "$FILE_WITH_SEPARATOR""_entrypoint"
	
	cat "$FILE_WITH_SEPARATOR""_dep" "$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME"  \
	"$FILE_WITH_SEPARATOR""_bootstrap" "$FILE_WITH_BOOTSTRAP_SANITIZED" \
	"$FILE_WITH_SEPARATOR" "$FILE_WITH_CAT_SH_LIBS" \
	"$FILE_WITH_SEPARATOR""_entrypoint" "$FILE_ENTRYPOINT_PATH" \
	"$FILE_WITH_SEPARATOR" "$FILE_WITH_CAT_SH_SRCS" \
		> "$COMPILED_FILE_PATH"
	
	shpm_log "- Remove extra lines ..."
	sed -i '/^$/d' "$COMPILED_FILE_PATH"
	
	shpm_log "- Remove tmp files ..."
	increase_g_indent
	#remove_file_if_exists "$FILE_WITH_CAT_SH_LIBS"
	#remove_file_if_exists "$FILE_WITH_CAT_SH_SRCS"
	#remove_file_if_exists "$FILE_WITH_BOOTSTRAP_SANITIZED"
	decrease_g_indent
	
	shpm_log "- Grant permissions in compiled file ..."
	chmod 755 "$COMPILED_FILE_PATH"

   	shpm_log ""	
	shpm_log "Compile pipeline finish."
   	shpm_log ""
	shpm_log "Compile successfull! File generated in:" "green"
	shpm_log "  |$COMPILED_FILE_PATH|"
	shpm_log ""
}