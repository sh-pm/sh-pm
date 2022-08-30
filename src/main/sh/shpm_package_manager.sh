run_update_dependencies() {
  shpm_log_operation "Update Dependencies"
  
  local verbose="$1"
  
  shpm_log "Start update of ${#DEPENDENCIES[@]} dependencies ..."
  for dep_artifact_id in "${!DEPENDENCIES[@]}"; do 
    update_dependency "$dep_artifact_id" "$verbose"
  done
  
  cd "$ROOT_DIR_PATH" || exit 1
  
  shpm_log "Done"
}

shpm_update_itself_after_git_clone() {
    shpm_log "WARN: sh-pm updating itself ..." "yellow"
    
    local path_to_dep_in_tmp
    local path_to_dep_in_project
    
    path_to_dep_in_tmp="$1"
    path_to_dep_in_project="$2"
    
    shpm_log "     - Copy $BOOTSTRAP_FILENAME to $path_to_dep_in_project ..."
  cp "$path_to_dep_in_tmp/$BOOTSTRAP_FILENAME" "$path_to_dep_in_project"
      
  shpm_log "     - Update $BOOTSTRAP_FILENAME sourcing command from shpm.sh file ..."
  sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh/source \.\/bootstrap.sh/g' "$path_to_dep_in_project/shpm.sh"
    
    if [[ -f "$ROOT_DIR_PATH/shpm.sh" ]]; then
      create_path_if_not_exists "$ROOT_DIR_PATH/tmpoldshpm"
      
      shpm_log "   - backup actual sh-pm version to $ROOT_DIR_PATH/tmpoldshpm ..."
      mv "$ROOT_DIR_PATH/shpm.sh" "$ROOT_DIR_PATH/tmpoldshpm"
    fi
    
    if [[ -f "$path_to_dep_in_project/shpm.sh" ]]; then
      shpm_log "   - update shpm.sh ..."
      cp "$path_to_dep_in_project/shpm.sh"  "$ROOT_DIR_PATH"
    fi
    
    if [[ -f "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" ]]; then
      shpm_log "   - backup actual $BOOTSTRAP_FILENAME to $ROOT_DIR_PATH/tmpoldshpm ..."
      mv "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" "$ROOT_DIR_PATH/tmpoldshpm"
    fi
    
    if [[ -f "$path_to_dep_in_project/$BOOTSTRAP_FILENAME" ]]; then
      shpm_log "   - update $BOOTSTRAP_FILENAME ..."
      cp "$path_to_dep_in_project/$BOOTSTRAP_FILENAME"  "$ROOT_DIR_PATH"
    fi
}

set_dependency_repository(){
  local dep_artifact_id
  local r2_dep_repository # (R)eference (2)nd: will be attributed to 2nd param by reference  
  local artifact_data
  
  dep_artifact_id="$1"
  artifact_data="${DEPENDENCIES[$dep_artifact_id]}"
  
  if [[ "$artifact_data" == *"@"* ]]; then
    r2_dep_repository=$( echo "$artifact_data" | cut -d "@" -f 2 | xargs ) #xargs is to trim string!
    
    if [[ "$r2_dep_repository" == "" ]]; then
      shpm_log "Error in $dep_artifact_id dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
      exit 1
    fi
  else
    shpm_log "Error in $dep_artifact_id dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
    exit 1
  fi
  
  eval "$2=$r2_dep_repository"
}

set_dependency_version(){
  local dep_artifact_id
  local r2_dep_version  # (R)eference (2)nd: will be attributed to 2nd param by reference
  
  dep_artifact_id="$1"
  
  local artifact_data="${DEPENDENCIES[$dep_artifact_id]}"
  if [[ "$artifact_data" == *"@"* ]]; then
    r2_dep_version=$( echo "$artifact_data" | cut -d "@" -f 1 | xargs ) #xargs is to trim string!            
  else
    shpm_log "Error in $dep_artifact_id dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
    exit 1
  fi
  
  eval "$2=$r2_dep_version"
}

update_dependency() {
  local dep_artifact_id=$1
  local verbose=$2
    
  local dep_version
  local repository
  local dep_folder_name
  local path_to_dep_in_project
  local path_to_dep_in_tmp
  
  local actual_dir
  
  actual_dir=$( pwd )
  
  create_path_if_not_exists "$LIB_DIR_PATH" 
  
  set_dependency_repository "$dep_artifact_id" repository 
  set_dependency_version "$dep_artifact_id" dep_version

  dep_folder_name="$dep_artifact_id""-""$dep_version"
  path_to_dep_in_project="$LIB_DIR_PATH/$dep_folder_name"
  path_to_dep_in_tmp="$TMP_DIR_PATH/$dep_artifact_id"
  
  shpm_log "----------------------------------------------------"
  reset_g_indent 
  increase_g_indent   
  shpm_log "Updating $dep_artifact_id to $dep_version: Start"        
   
  increase_g_indent
  
  if download_from_git_to_tmp_folder "$repository" "$dep_artifact_id" "$dep_version"; then
  
    remove_folder_if_exists "$path_to_dep_in_project"    
    create_path_if_not_exists "$path_to_dep_in_project"
        
    shpm_log "- Copy artifacts from $path_to_dep_in_tmp to $path_to_dep_in_project ..."
    cp "$path_to_dep_in_tmp/src/main/sh/"* "$path_to_dep_in_project"
    cp "$path_to_dep_in_tmp/pom.sh" "$path_to_dep_in_project"
    
    # if update a sh-pm
    if [[ "$dep_artifact_id" == "sh-pm" ]]; then
      shpm_update_itself_after_git_clone "$path_to_dep_in_tmp" "$path_to_dep_in_project"
    fi
    
    shpm_log "- Removing $path_to_dep_in_tmp ..."
    increase_g_indent
    remove_folder_if_exists "$path_to_dep_in_tmp"
    decrease_g_indent
    
    cd "$actual_dir" || exit
  
  else              
       shpm_log "$dep_artifact_id was not updated to $dep_version!"
  fi
  
  decrease_g_indent   
  shpm_log "Update $dep_artifact_id to $dep_version: Finish"
  
  reset_g_indent 
  
  cd "$actual_dir" || exit 1
}
