export GIT_REMOTE_USERNAME=""
export GIT_REMOTE_PASSWORD=""

read_git_username_and_password() {
  if [[ -z "$GIT_REMOTE_USERNAME" ]]; then
    echo "GitHub username: "
    read -r GIT_REMOTE_USERNAME
    
    export GIT_REMOTE_USERNAME
  else
    echo "Advice: GitHub username already defined"
  fi
  
  if [[ -z "$GIT_REMOTE_PASSWORD" ]]; then
    echo "GitHub password: "
    read -r -s GIT_REMOTE_PASSWORD    
    GIT_REMOTE_PASSWORD="${GIT_REMOTE_PASSWORD//@/%40}"

    export GIT_REMOTE_PASSWORD
  else
    echo "Advice: GitHub password already defined"
  fi
}

git_clone() {
  local git_cmd
  local repository
  local dep_artifact_id
  local dep_version
  
  repository=$1
  dep_artifact_id=$2
  dep_version=$3
  
  git_cmd="$(which git)"

  if "$git_cmd" clone --branch "$dep_version" "https://""$repository""/""$dep_artifact_id"".git"; then
    return $TRUE
  fi
  return $FALSE
}

download_from_git_to_tmp_folder() {
  local git_cmd
  local repository
  local dep_artifact_id
  local dep_version
  
  repository=$1
  dep_artifact_id=$2
  dep_version=$3

  remove_folder_if_exists "$TMP_DIR_PATH/$dep_artifact_id"
  
  cd "$TMP_DIR_PATH" || exit
  
  git_cmd="$(which git)"

  shpm_log "- Cloning from https://$repository/$dep_artifact_id into /tmp/$dep_artifact_id ..."
  shpm_log "    $git_cmd clone --branch $dep_version https://$repository/$dep_artifact_id.git"
  if git_clone "$repository" "$dep_artifact_id" "$dep_version" &>/dev/null ; then
    return $TRUE
  fi
  return $FALSE
}

create_new_remote_branch_from_master_branch() {
  local actual_branch
  local master_branch
  local git_cmd
  
  local git_host
  local git_repo
  local git_project
  local git_user
  local git_passwd
  local original_branch
  local new_branch
  
  git_host="$1"
  #git_repo="$2"
  git_project="$3"
  git_user="$4"
  #git_passwd="$5"
  original_branch="$6"
  new_branch="$7"
  
  GIT_ORIGINAL_URL="https://$git_host/$git_user/$git_project.git"
  
  if [[ "$new_branch" != "" ]]; then
    git_cmd=$( which git )
    
    REMOTE_BRANCH_FOUND=$( git branch -r | grep "origin/$new_branch" | xargs )
    if [[ ! -z "$REMOTE_BRANCH_FOUND" ]]; then  # if branch already exists
      #TODO: ???
      echo "PENDING IMPLEMENTATION!!!" && exit 1
    else
      echo "Create new local branch"
      $git_cmd branch "$new_branch" || exit 1    
    fi
    
    
    echo "Go to new branch"
    $git_cmd checkout "$new_branch" || exit 1

    echo "Commit staged changes to local master"
    $git_cmd add .  || exit 1
    $git_cmd commit -m "Test" -m "Creation new branch with name $new_branch"  || exit 1
    
    echo "Push branch to remote"
    $git_cmd push -u "$GIT_ORIGINAL_URL" "$new_branch"  || exit 1
    
    echo "Goto $original_branch branch again"
    $git_cmd checkout "$original_branch"  || exit 1
    
    echo "Fetch to local branch \"see\" new remote branch"
    $git_cmd fetch  || exit 1
  fi
}
