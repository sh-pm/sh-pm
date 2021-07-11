#!/usr/bin/env bash

array_contain_element() {
	local -n P_ARRAY="$1"
	local ELEMENT="$2"
	
	for iter in "${P_ARRAY[@]}"; do
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
	
	grep "$MANIFEST_P_ENTRY_POINT_FILE" "$MANIFEST_FILE_PATH" | cut -d '=' -f 2
	
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
	right_pad_string "" 133 "#"
}

remove_problematic_lines_of_concat_lib_file() {
	shpm_log "- Remove problematic lines in all .sh lib files ..."
	grep -v "$PATTERN_INCLUDE_BOOTSTRAP_FILE" < "$FILE_WITH_CAT_SH_LIBS""_tmp" | grep -v "$SHEBANG_FIRST_LINE" | grep -v "$INCLUDE_LIB_AND_FILE" > "$FILE_WITH_CAT_SH_LIBS"
}

display_running_compiler_msg() {	
	shpm_log "\nRunning compile pipeline:\n"
}


concat_all_files_of_folder() {
	shpm_log "- Concat all .sh lib files that will be used in compile ..."
	
	local P_FOLDER
	local SEPARATOR_DESCRIPTION
	local OUTPUT_CONCAT_FILE
	local SEPARATOR_DESCRIPTION
	local AUX_FILEPATH
	
	local FILES_TO_CONCAT
	
	P_FOLDER="$1"
	SEPARATOR_DESCRIPTION="$2"
	OUTPUT_CONCAT_FILE="$3"
	
	FILES_TO_CONCAT=$( find "$P_FOLDER"  -type f ! -name "$DEPENDENCIES_FILENAME" ! -name 'sh-pm*' -name '*.sh' )

	AUX_FILEPATH="$TMP_DIR_PATH/tmp_separator_aux_file"
	
	for file in "${FILES_TO_CONCAT[@]}"; do
		SEPARATOR_DESCRIPTION=$( basename "$file" )
		
		create_tmp_file_to_store_file_separator "$SEPARATOR_DESCRIPTION" "$AUX_FILEPATH"
		
		cat "$AUX_FILEPATH" "$file" >> "$OUTPUT_CONCAT_FILE"
	done
}

create_tmp_file_to_store_section_separator() {
	local SEPARATOR_DESCRIPTION
	local FILECONTENT_SEP
	local PATH_TO_TMP_FILE_STORE_SEPARATOR
	
	SEPARATOR_DESCRIPTION="$1"
	PATH_TO_TMP_FILE_STORE_SEPARATOR="$2"
	
	FILECONTENT_SEP=$( right_pad_string "#" 140 ">" )
	
	echo -e "\n$FILECONTENT_SEP\n# $SEPARATOR_DESCRIPTION\n$FILECONTENT_SEP\n" > "$PATH_TO_TMP_FILE_STORE_SEPARATOR"
}

create_tmp_file_to_store_file_separator() {
	local SEPARATOR_DESCRIPTION="$1"
	local PATH_TO_TMP_FILE_STORE_SEPARATOR="$2"

	FILECONTENT_SEP=$( right_pad_string "" 110 "#" )
	 		
	echo "#### $SEPARATOR_DESCRIPTION ${FILECONTENT_SEP:0:-${#SEPARATOR_DESCRIPTION}}" > "$PATH_TO_TMP_FILE_STORE_SEPARATOR"
}

concat_all_src_files(){
	shpm_log "- Concat all .sh src files that will be used in compile except entrypoint file ..."
		
	local SRC_FILES
	local FILE_ENTRYPOINT_PATH
	
	SRC_FILES=$( find "$SRC_DIR_PATH"  -type f ! -path "sh-pm*" ! -name "pom.sh" -name '*.sh' )
	FILE_ENTRYPOINT_PATH=""
	
	update_section_separator "SOURCES"	
	
	cat "$FILE_WITH_SEPARATOR" >> "$FILE_WITH_CAT_SH_SRCS""_tmp"
	
	for file in "${SRC_FILES[@]}"; do
		if [[ "$FILE_ENTRYPOINT_NAME" != "$( basename "$file" )" ]]; then
			update_file_separator "$file"
			cat "$FILE_WITH_SEPARATOR" "$file" >> "$FILE_WITH_CAT_SH_SRCS""_tmp"
		fi 		
	done
}

get_entrypoint_filepath(){
	local SRC_FILES
	
	SRC_FILES=$( find "$SRC_DIR_PATH"  -type f ! -path "sh-pm*" ! -name "pom.sh" -name '*.sh' )
	
	for file in "${SRC_FILES[@]}"; do
		if [[ "$FILE_ENTRYPOINT_NAME" == "$( basename "$file" )" ]]; then
			echo "$file"
		fi	
	done
}


remove_unwanted_lines_of_files() {
	local P_FOLDER
	
	P_FOLDER="$1"

	for file in $(find "$P_FOLDER" -type f ); do
		remove_unwanted_lines_in_compilation "$file" "$file"
	done
}

remove_unwanted_lines_in_compilation() {
	local INPUT_FILE="$1"
	local OUTPUT_FILE="$2"
	
	local PATTERN_INCLUDE_LIB_AND_FILE
	local PATTERN_SHEBANG_FIRST_LINE
	
	local PATTERN_INCLUDE_BOOTSTRAP_FILE_1
	local PATTERN_INCLUDE_BOOTSTRAP_FILE_2
	local PATTERN_INCLUDE_BOOTSTRAP_FILE
	
	local PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_1
	local PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE_2
	local PATTERN_SOURCE_DEPSFILE_CMD_IN_BOOTSTRAP_FILE
	
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

prepare_libraries() {
	shpm_log "- Prepare libraries:"
	
	local TMP_COMPILE_WORKDIR	
	local TMP_COMPILE_LIBS_FOLDER_PATH
	local TMP_LIBS_CONCAT_FILENAME
	local FOLDER_PATH
	
	TMP_COMPILE_WORKDIR=$( get_tmp_compilation_dir )
	FOLDER_PATH="$1"
	TMP_LIBS_CONCAT_FILENAME="$2"
	TMP_COMPILE_LIBS_FOLDER_PATH="$TMP_COMPILE_WORKDIR/libs"
	
   	increase_g_indent
   	
   	create_path_if_not_exists "$TMP_COMPILE_LIBS_FOLDER_PATH"
   	
   	cp -r "$FOLDER_PATH" "$TMP_COMPILE_LIBS_FOLDER_PATH"
	
	ensure_newline_at_end_of_files "$TMP_COMPILE_LIBS_FOLDER_PATH"
   		                     
	concat_all_files_of_folder "$TMP_COMPILE_LIBS_FOLDER_PATH" "LIBRARIES" "$TMP_LIBS_CONCAT_FILENAME""_tmp"
	
	remove_unwanted_lines_in_compilation "$TMP_LIBS_CONCAT_FILENAME""_tmp" "$TMP_LIBS_CONCAT_FILENAME"

	remove_file_if_exists "$TMP_LIBS_CONCAT_FILENAME""_tmp"
	
	add_section_delimiter_at_start_of_file "LIBRARIES" "$TMP_SRCS_CONCAT_FILEPATH"
	
   	decrease_g_indent
}

prepare_source_code() {
	shpm_log "- Prepare source code:"
	
	local TMP_COMPILE_WORKDIR
	local TMP_COMPILE_SRCS_FOLDER_PATH
	local TMP_SRCS_CONCAT_FILENAME
	
	TMP_COMPILE_WORKDIR=$( get_tmp_compilation_dir )
	
	FOLDER_PATH="$1"
	TMP_SRCS_CONCAT_FILEPATH="$2"
	TMP_COMPILE_SRCS_FOLDER_PATH="$TMP_COMPILE_WORKDIR/srcs"
	
   	increase_g_indent
   	
   	create_path_if_not_exists "$TMP_COMPILE_SRCS_FOLDER_PATH"
   	
   	cp "$FOLDER_PATH" "$TMP_COMPILE_SRCS_FOLDER_PATH"
	
	ensure_newline_at_end_of_files "$TMP_COMPILE_SRCS_FOLDER_PATH"
   		                     
	concat_all_files_of_folder "$TMP_COMPILE_SRCS_FOLDER_PATH" "SOURCES" "$TMP_SRCS_CONCAT_FILEPATH""_tmp"
	
	remove_unwanted_lines_in_compilation "$TMP_SRCS_CONCAT_FILEPATH""_tmp" "$TMP_SRCS_CONCAT_FILEPATH"
	
	add_section_delimiter_at_start_of_file "SOURCES" "$TMP_SRCS_CONCAT_FILEPATH"
	
	remove_file_if_exists "$TMP_SRCS_CONCAT_FILEPATH""_tmp"
		
   	decrease_g_indent
}

prepare_dep_file() {
	shpm_log "- Prepare $DEPENDENCIES_FILENAME:"
	
	local DEP_FILE_PATH
	local OUTPUT_FILE_PATH
	local TMP_COMPILE_WORKDIR
	
	DEP_FILE_PATH="$1";
	OUTPUT_FILE_PATH="$1";
	
	TMP_COMPILE_WORKDIR=$( get_tmp_compilation_dir )
	
	increase_g_indent
   	
   	create_path_if_not_exists "$TMP_COMPILE_WORKDIR"
   	
   	cp "$DEP_FILE_PATH" "$OUTPUT_FILE_PATH"
   	
   	ensure_newline_at_end_of_file "$OUTPUT_FILE_PATH"
	
	add_section_delimiter_at_start_of_file "$DEPENDENCIES_FILENAME" "$OUTPUT_FILE_PATH"
	
	decrease_g_indent
}

prepare_bootstrap_file() {
	shpm_log "- Prepare $BOOTSTRAP_FILENAME:"
	
	local DEP_FILE_PATH
	local OUTPUT_FILE_PATH
	local TMP_COMPILE_WORKDIR
	
	DEP_FILE_PATH="$1";
	OUTPUT_FILE_PATH="$1";
	
	TMP_COMPILE_WORKDIR=$( get_tmp_compilation_dir )
	
	increase_g_indent
   	
   	create_path_if_not_exists "$TMP_COMPILE_WORKDIR"
   	
   	cp "$DEP_FILE_PATH" "$OUTPUT_FILE_PATH"
   	
   	ensure_newline_at_end_of_file "$OUTPUT_FILE_PATH"
	
	add_section_delimiter_at_start_of_file "$BOOTSTRAP_FILENAME" "$OUTPUT_FILE_PATH"
	
	decrease_g_indent
}

add_section_delimiter_at_start_of_file() {
	local SECTION_DESCRIPTION
	local FILE_PATH
	local AUX_FILE_WITH_SEP
	
	SECTION_DESCRIPTION="$1"
	FILE_PATH="$2"
	
	AUX_FILE_WITH_SEP="$TMP_DIR_PATH/tmp_file_store_separator"
	
	create_tmp_file_to_store_section_separator "$SECTION_DESCRIPTION" "$AUX_FILE_WITH_SEP"
	
	cp "$FILE_PATH" "$FILE_PATH""_addsectiontmp"
	
	cat "$AUX_FILE_WITH_SEP" "$FILE_PATH""_addsectiontmp" > "$FILE_PATH"
	
	remove_file_if_exists "$FILE_PATH""_addsectiontmp" 
}

get_handled_fileentrypoint_path() {
	local FILE_ENTRY_POINT_PATH="$1"
	echo "$TMP_COMPILE_WORKDIR/$(basename $FILE_ENTRYPOINT_PATH)"
}

prepare_fileentrypoint(){
	local FILE_ENTRYPOINT_PATH
	local FILE_ENTRYPOINT_NAME
	
	FILE_ENTRYPOINT_NAME="$( get_entrypoint_filename )"
	FILE_ENTRYPOINT_PATH="$( get_entrypoint_filepath )"

	create_file_separator "$FILE_ENTRYPOINT_PATH" "$FILE_WITH_SEPARATOR""_entrypoint"
	
	HANDLED_FILE_ENTRYPOINT_PATH=$( get_handled_fileentrypoint_path "$FILE_ENTRYPOINT_PATH" )
	
	cp "$FILE_ENTRYPOINT_PATH" "$HANDLED_FILE_ENTRYPOINT_PATH"
	
	ensure_newline_at_end_of_file "HANDLED_FILE_ENTRYPOINT_PATH"
	
	remove_problematic_lines_of_entryfile
}

ensure_newline_at_end_of_files() {
	local FOLDER_PATH
	FOLDER_PATH="$1"
	
	for file in $(find "$FOLDER_PATH" -type f ! -name "$DEPENDENCIES_FILENAME" ! -name 'sh-pm*' -name '*.sh'); do
		ensure_newline_at_end_of_file "$file"
	done
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
	local TMP_COMPILE_WORKDIR
	TMP_COMPILE_WORKDIR=$( get_tmp_compilation_dir )
	
	remove_folder_if_exists "$TMP_COMPILE_WORKDIR"
	create_path_if_not_exists "$TMP_COMPILE_WORKDIR"
}

run_compile_app() {
	
	shpm_log_operation "Compile Application"
		
	local FILE_ENTRYPOINT_NAME
	local FILE_ENTRYPOINT_PATH
	
	local TMP_COMPILE_WORKDIR
	
	local FILE_WITH_CAT_SH_LIBS
	local FILE_WITH_CAT_SH_SRCS
	local FILE_WITH_SEPARATOR
	local FILE_WITH_BOOTSTRAP_SANITIZED
	local COMPILED_FILE_NAME
	local COMPILED_FILE_PATH

	if [[ ! -f "$MANIFEST_FILE_PATH" ]]; then
		shpm_log "\nERROR: $MANIFEST_FILE_PATH not found!\n" "red"
		return "$FALSE"
	fi
	
	local TMP_COMPILE_WORKDIR
	TMP_COMPILE_WORKDIR=$( get_tmp_compilation_dir )
	
	FILE_WITH_CAT_SH_LIBS="$TMP_COMPILE_WORKDIR/lib_files_concat"
	FILE_WITH_CAT_SH_SRCS="$TMP_COMPILE_WORKDIR/sh_files_concat"
	FILE_WITH_SEPARATOR="$TMP_COMPILE_WORKDIR/separator"
	FILE_WITH_BOOTSTRAP_SANITIZED="$TMP_COMPILE_WORKDIR/$BOOTSTRAP_FILENAME"
	FILE_WITH_DEPS_SANITIZED="$TMP_COMPILE_WORKDIR/$DEPENDENCIES_FILENAME"
	
	display_running_compiler_msg
	
   	create_path_if_not_exists "$TARGET_DIR_PATH"
   	
   	reset_tmp_compilation_dir

   	prepare_libraries "$LIB_DIR_PATH" "$FILE_WITH_CAT_SH_LIBS"

	prepare_source_code "$SRC_DIR_PATH" "$FILE_WITH_CAT_SH_SRCS"

	prepare_dep_file "$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME" "$FILE_WITH_DEPS_SANITIZED"
	
	prepare_bootstrap_file "$FILE_WITH_BOOTSTRAP_SANITIZED"
		
	prepare_fileentrypoint
	
	HANDLED_FILE_ENTRYPOINT_PATH=$( get_handled_fileentrypoint_path "$FILE_ENTRYPOINT_PATH" )

	shpm_log "- Generate compiled file ..."
	
	remove_file_if_exists "$COMPILED_FILE_PATH"
	
	
	COMPILED_FILE_NAME=$( get_compiled_filename ) 	
	COMPILED_FILE_PATH="$TARGET_DIR_PATH/$COMPILED_FILE_NAME"
	
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
