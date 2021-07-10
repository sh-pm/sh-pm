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

right_pad_string() {
	printf %-"$2"s "$1" | tr ' ' "$3"
}

left_pad_string() {
	printf %"$2"s "$1" | tr ' ' "$3"
}

#--------------------------------------------

get_entrypoint_filename() {
	
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

display_file_entrypoint_error_message() {
	shpm_log ""
	shpm_log "ERROR: Inform \"$MANIFEST_P_ENTRY_POINT_FILE\" propertie value in file: $MANIFEST_FILE_PATH!" "red"
	shpm_log ""
	shpm_log "Exemple content of $MANIFEST_FILENAME file:"
	shpm_log ""
	shpm_log "$MANIFEST_P_ENTRY_POINT_FILE""=""foo.sh"
	shpm_log "$MANIFEST_P_ENTRY_POINT_FUNCTION""=""main"
	shpm_log ""
}

get_file_separator_delimiter_line() {
	echo -e $( right_pad_string "" 133 "#" )
}

ensure_newline_at_end_of_files() {
	local FOLDER_PATH
	FOLDER_PATH="$1"
	
	for file in $(find "$FOLDER_PATH" -type f ! -name "$DEPENDENCIES_FILENAME" ! -name 'sh-pm*' -name '*.sh'); do
		ensure_newline_at_end_of_file "$file"
	done
}

ensure_newline_at_end_of_lib_files() {
	shpm_log "- Ensure \\\n in end of lib files to prevent file concatenation errors ..."
	ensure_newline_at_end_of_files "$LIB_DIR_PATH"
}

remove_problematic_lines_of_concat_lib_file() {
	shpm_log "- Remove problematic lines in all .sh lib files ..."
	grep -v "$PATTERN_INCLUDE_BOOTSTRAP_FILE" < "$FILE_WITH_CAT_SH_LIBS""_tmp" | grep -v "$SHEBANG_FIRST_LINE" | grep -v "$INCLUDE_LIB_AND_FILE" > "$FILE_WITH_CAT_SH_LIBS"
}

prepare_libraries() {
	shpm_log "- Prepare libraries:"
	
   	increase_g_indent
   	   	
   	ensure_newline_at_end_of_lib_files
   		                     
	concat_all_lib_files
	
	remove_problematic_lines_of_concat_lib_file
		
	remove_file_if_exists "$FILE_WITH_CAT_SH_LIBS""_tmp"
		
   	decrease_g_indent
}

display_running_compiler_msg() {	
	shpm_log "\nRunning compile pipeline:\n"
}

concat_all_lib_files() {
	shpm_log "- Concat all .sh lib files that will be used in compile ..."
			
	local LIB_FILES=$( find "$LIB_DIR_PATH"  -type f ! -name "$DEPENDENCIES_FILENAME" ! -name 'sh-pm*' -name '*.sh' )
	
	local FILENAME
	
	update_section_separator "LIBRARIES"	
	cat "$FILE_WITH_SEPARATOR" >> "$FILE_WITH_CAT_SH_LIBS""_tmp"
	
	for file in ${LIB_FILES[@]}; do
	
		update_file_separator "$file"
		
		cat "$FILE_WITH_SEPARATOR" "$file" >> "$FILE_WITH_CAT_SH_LIBS""_tmp"
	done
}

update_section_separator() {
	local STR_AUX="$1"
	
	local FILECONTENT_SEP=$( right_pad_string "#" 140 ">" )
	
	echo -e "\n\n$FILECONTENT_SEP\n# $STR_AUX \n$FILECONTENT_SEP\n\n" > "$FILE_WITH_SEPARATOR"
}

create_file_separator() {
	local file="$1"
	local PATH_TO_FILE_CONTAINING_SEPARATOR="$2"

	FILENAME_AUX=$( basename "$file" )
			
	FILECONTENT_SEP=$( right_pad_string "" 110 "#" )
	 		
	echo "#### $FILENAME_AUX ${FILECONTENT_SEP:0:-${#FILENAME_AUX}}" > "$PATH_TO_FILE_CONTAINING_SEPARATOR"
}

update_file_separator() {
	local file="$1"

	FILENAME_AUX=$( basename "$file" )
			
	FILECONTENT_SEP=$( right_pad_string "" 110 "#" )
	 		
	echo "#### $FILENAME_AUX ${FILECONTENT_SEP:0:-${#FILENAME_AUX}}" > "$FILE_WITH_SEPARATOR"
}

concat_all_src_files(){
	shpm_log "- Concat all .sh src files that will be used in compile except entrypoint file ..."
		
	local SRC_FILES=$( find "$SRC_DIR_PATH"  -type f ! -path "sh-pm*" ! -name "pom.sh" -name '*.sh' )
	local FILE_ENTRYPOINT_PATH=""
	
	update_section_separator "SOURCES"	
	
	cat "$FILE_WITH_SEPARATOR" >> "$FILE_WITH_CAT_SH_SRCS""_tmp"
	
	for file in ${SRC_FILES[@]}; do
		if [[ "$FILE_ENTRYPOINT_NAME" != "$( basename "$file" )" ]]; then
			update_file_separator "$file"
			cat "$FILE_WITH_SEPARATOR" "$file" >> "$FILE_WITH_CAT_SH_SRCS""_tmp"
		fi 		
	done
}

get_entrypoint_filepath(){
	local SRC_FILES=$( find "$SRC_DIR_PATH"  -type f ! -path "sh-pm*" ! -name "pom.sh" -name '*.sh' )
	
	for file in ${SRC_FILES[@]}; do
		if [[ "$FILE_ENTRYPOINT_NAME" == "$( basename "$file" )" ]]; then
			echo "$file"
		fi	
	done
}


remove_problematic_lines_of_src_concat_file() {
	shpm_log "- Remove problematic lines in all .sh src files ..."
	remove_unwanted_lines_in_compilation "$FILE_WITH_CAT_SH_SRCS""_tmp" "$FILE_WITH_CAT_SH_SRCS"
	remove_file_if_exists "$FILE_WITH_CAT_SH_SRCS""_tmp"
}

remove_problematic_lines_of_entryfile() {
	HANDLED_FILE_ENTRYPOINT_PATH=$( get_handled_fileentrypoint_path )
	shpm_log "- Remove problematic lines in $HANDLED_FILE_ENTRYPOINT_PATH files ..."
	
	cp "$HANDLED_FILE_ENTRYPOINT_PATH" "$HANDLED_FILE_ENTRYPOINT_PATH""_tmp"
	
	remove_unwanted_lines_in_compilation "$HANDLED_FILE_ENTRYPOINT_PATH""_tmp" "$HANDLED_FILE_ENTRYPOINT_PATH"
	
	remove_file_if_exists "$HANDLED_FILE_ENTRYPOINT_PATH""_tmp"
}

remove_unwanted_lines_in_compilation() {
	local INPUT_FILE="$1"
	local OUTPUT_FILE="$2"
	
	local PATTERN_INCLUDE_LIB_AND_FILE
	local PATTERN_SHEBANG_FIRST_LINE
	
	local PATTERN_INCLUDE_BOOTSTRAP_FILE_1
	local PATTERN_INCLUDE_BOOTSTRAP_FILE_2
	local PATTERN_INCLUDE_BOOTSTRAP_FILE
	
	local SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_1
	local SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_2
	local SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE
	
	#---------------------------------------
	
	PATTERN_INCLUDE_LIB_AND_FILE="include_lib\|include_file"
	PATTERN_SHEBANG_FIRST_LINE="#!/bin/bash\|#!/usr/bin/env bash"
	
	PATTERN_INCLUDE_BOOTSTRAP_FILE_1="source ./$BOOTSTRAP_FILENAME"
	PATTERN_INCLUDE_BOOTSTRAP_FILE_2="source ../../../$BOOTSTRAP_FILENAME"
	PATTERN_INCLUDE_BOOTSTRAP_FILE="$PATTERN_INCLUDE_BOOTSTRAP_FILE_1\|$PATTERN_INCLUDE_BOOTSTRAP_FILE_2"
	
	PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_1='source "$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME"'
	PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_2='source "$ROOT_DIR_PATH/'"$DEPENDENCIES_FILENAME"
	PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE="$PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_1\|$PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_2"

	#---------------------------------------
	
	grep -v "$PATTERN_INCLUDE_BOOTSTRAP_FILE" < "$INPUT_FILE" \
	| grep -v "$PATTERN_SHEBANG_FIRST_LINE" \
	| grep -v "$PATTERN_INCLUDE_LIB_AND_FILE" \
	| grep -v "$PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE" \
	> "$OUTPUT_FILE"
}

prepare_source_code() {
   	shpm_log "- Prepare source code:"
   	increase_g_indent
   	
 	ensure_newline_at_end_of_src_files
	
	concat_all_src_files
	
	remove_problematic_lines_of_src_concat_file

	shpm_log "- Remove problematic lines in $ROOT_DIR_PATH/$BOOTSTRAP_FILENAME file ..."
	grep -v "$SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE" < "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" | grep -v "$SHEBANG_FIRST_LINE" > "$FILE_WITH_BOOTSTRAP_SANITIZED"  
   	decrease_g_indent
}

prepare_dep_file() {
	ensure_newline_at_end_of_dep_file
	local DEP_FILE_PATH="$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME";
	create_file_separator "$DEP_FILE_PATH" "$FILE_WITH_SEPARATOR""_dep"
}

prepare_bootstrap_file() {
	ensure_newline_at_end_of_bootstrap_file
	local BOOTSTRAP_FILE_PATH="$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME";
	create_file_separator "$BOOTSTRAP_FILE_PATH" "$FILE_WITH_SEPARATOR""_bootstrap"
}

get_handled_fileentrypoint_path() {
	local FILE_ENTRY_POINT_PATH="$1"
	echo "$TMP_COMPILE_WORKDIR/$(basename $FILE_ENTRYPOINT_PATH)"
}

prepare_fileentrypoint(){
	local FILE_ENTRY_POINT_PATH="$1"

	create_file_separator "$FILE_ENTRYPOINT_PATH" "$FILE_WITH_SEPARATOR""_entrypoint"
	
	reset_tmp_compilation_dir "$TMP_COMPILE_WORKDIR"
	
	HANDLED_FILE_ENTRYPOINT_PATH=$( get_handled_fileentrypoint_path "$FILE_ENTRY_POINT_PATH" )
	
	cp "$FILE_ENTRYPOINT_PATH" "$HANDLED_FILE_ENTRYPOINT_PATH"
	
	ensure_newline_at_end_of_file "HANDLED_FILE_ENTRYPOINT_PATH"
	
	remove_problematic_lines_of_entryfile
}

ensure_newline_at_end_of_src_files() {
  	shpm_log "- Ensure \\\n in end of src files to prevent file concatenation errors ..."
	find "$SRC_DIR_PATH"  -type f ! -path "sh-pm*" ! -name "$DEPENDENCIES_FILENAME" -name '*.sh' -exec sed -i -e '$a\' {} \;
}

ensure_newline_at_end_of_dep_file() {
  	shpm_log "- Ensure \\\n in end of src files to prevent file concatenation errors ..."
	find "$ROOT_DIR_PATH"  -type f ! -path "sh-pm*" -name "$DEPENDENCIES_FILENAME" -exec sed -i -e '$a\' {} \;
}

ensure_newline_at_end_of_bootstrap_file() {
  	shpm_log "- Ensure \\\n in end of src files to prevent file concatenation errors ..."
	find "$ROOT_DIR_PATH"  -type f ! -path "sh-pm*" -name "$BOOTSTRAP_FILENAME" -exec sed -i -e '$a\' {} \;
}

ensure_newline_at_end_of_file() {
	local P_FILEPATH="$1"
  	shpm_log "- Ensure \\\n in end of $( basename $P_FILEPATH ) file to prevent file concatenation errors ..."
	echo -e "\n" >> "$P_FILEPATH"
}

get_tmp_compilation_dir() {
	echo "$TMP_DIR_PATH/compilation_$(date '+%s')"
}

reset_tmp_compilation_dir() {
	local TMP_COMPILE_WORKDIR="$1"
	
	remove_folder_if_exists "$TMP_COMPILE_WORKDIR"
	create_path_if_not_exists "$TMP_COMPILE_WORKDIR"
}

run_compile_app() {
	
	shpm_log_operation "Compile Application"
		
	if [[ ! -f "$MANIFEST_FILE_PATH" ]]; then
		shpm_log "\nERROR: $MANIFEST_FILE_PATH not found!\n" "red"
		return $FALSE
	fi
	
	local FILE_ENTRYPOINT_NAME
	local FILE_ENTRYPOINT_PATH
	
	local TMP_COMPILE_WORKDIR
	
	local FILE_WITH_CAT_SH_LIBS
	local FILE_WITH_CAT_SH_SRCS
	local FILE_WITH_SEPARATOR
	local FILE_WITH_BOOTSTRAP_SANITIZED
	local COMPILED_FILE_NAME
	local COMPILED_FILE_PATH
	
	FILE_ENTRYPOINT_NAME="$( get_entrypoint_filename )"
	FILE_ENTRYPOINT_PATH="$( get_entrypoint_filepath )"
	
	TMP_COMPILE_WORKDIR=$( get_tmp_compilation_dir ) 
	
	reset_tmp_compilation_dir "$TMP_COMPILE_WORKDIR"	
	
	if [[ -z "$FILE_ENTRYPOINT_NAME" ]]; then
		display_file_entrypoint_error_message
		return $FALSE
	fi
	
	FILE_WITH_CAT_SH_LIBS="$TMP_DIR_PATH/lib_files_concat"
	FILE_WITH_CAT_SH_SRCS="$TMP_DIR_PATH/sh_files_concat"
	FILE_WITH_SEPARATOR="$TMP_DIR_PATH/separator"
	FILE_WITH_BOOTSTRAP_SANITIZED="$TMP_DIR_PATH/$BOOTSTRAP_FILENAME"
	
   	create_path_if_not_exists "$TARGET_DIR_PATH"
   
   	COMPILED_FILE_NAME=$( get_compiled_filename ) 
	
	COMPILED_FILE_PATH="$TARGET_DIR_PATH/$COMPILED_FILE_NAME"
	
	display_running_compiler_msg

   	prepare_libraries

	prepare_source_code

	prepare_dep_file
	
	prepare_bootstrap_file
		
	prepare_fileentrypoint "$FILE_ENTRY_POINT_PATH"
	HANDLED_FILE_ENTRYPOINT_PATH=$( get_handled_fileentrypoint_path "$FILE_ENTRY_POINT_PATH" )

	shpm_log "- Generate compiled file ..."
	
	remove_file_if_exists "$COMPILED_FILE_PATH"
	
	cat \
		"$FILE_WITH_SEPARATOR""_dep" "$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME"  \
		"$FILE_WITH_SEPARATOR""_bootstrap" "$FILE_WITH_BOOTSTRAP_SANITIZED" \
		"$FILE_WITH_SEPARATOR" "$FILE_WITH_CAT_SH_LIBS" \
		"$FILE_WITH_SEPARATOR" "$FILE_WITH_CAT_SH_SRCS" \
		"$FILE_WITH_SEPARATOR""_entrypoint" "$HANDLED_FILE_ENTRYPOINT_PATH" \
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


run_compile_lib() {
	
	shpm_log_operation "Compile Library"
	
	local FILE_WITH_CAT_SH_SRCS
	local FILE_WITH_SEPARATOR
	local COMPILED_FILE_NAME
	local COMPILED_FILE_PATH
	
	FILE_WITH_CAT_SH_SRCS="$TMP_DIR_PATH/sh_files_concat"
	FILE_WITH_SEPARATOR="$TMP_DIR_PATH/separator"
	FILE_WITH_BOOTSTRAP_SANITIZED="$TMP_DIR_PATH/$BOOTSTRAP_FILENAME"
	
   	create_path_if_not_exists "$TARGET_DIR_PATH"
   
   	COMPILED_FILE_NAME=$( get_compiled_filename ) 
	
	COMPILED_FILE_PATH="$TARGET_DIR_PATH/$COMPILED_FILE_NAME"
		
	display_running_compiler_msg

	prepare_source_code

	remove_file_if_exists "$COMPILED_FILE_PATH"
	
	shpm_log "- Generate compiled file ..."
	
	cat "$FILE_WITH_CAT_SH_SRCS" > "$COMPILED_FILE_PATH"
	
	shpm_log "- Remove extra lines ..."
	sed -i '/^$/d' "$COMPILED_FILE_PATH"
	
	shpm_log "- Remove tmp files ..."
	increase_g_indent
	remove_file_if_exists "$FILE_WITH_CAT_SH_SRCS"
	
	decrease_g_indent
	
	shpm_log "- Grant permissions in compiled file ..."

   	shpm_log ""	
	shpm_log "Compile pipeline finish."
   	shpm_log ""
	shpm_log "Compile successfull! File generated in:" "green"
	shpm_log "  |$COMPILED_FILE_PATH|"
	shpm_log ""
}
