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
	local GIT_CMD
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY=$1
	DEP_ARTIFACT_ID=$2
	DEP_VERSION=$3
	
	GIT_CMD="$(which git)"

	if "$GIT_CMD" clone --branch "$DEP_VERSION" "https://""$REPOSITORY""/""$DEP_ARTIFACT_ID"".git"; then
		return $TRUE
	fi
	return $FALSE
}

download_from_git_to_tmp_folder() {
	local GIT_CMD
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY=$1
	DEP_ARTIFACT_ID=$2
	DEP_VERSION=$3

	remove_folder_if_exists "$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	
	cd "$TMP_DIR_PATH" || exit
	
	GIT_CMD="$(which git)"

	shpm_log "- Cloning from https://$REPOSITORY/$DEP_ARTIFACT_ID into /tmp/$DEP_ARTIFACT_ID ..."
	shpm_log "    $GIT_CMD clone --branch $DEP_VERSION https://$REPOSITORY/$DEP_ARTIFACT_ID.git"
	if git_clone "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION" &>/dev/null ; then
		return $TRUE
	fi
	return $FALSE
}

create_new_remote_branch_from_master_branch() {
	local ACTUAL_BRANCH
	local MASTER_BRANCH
	local GIT_CMD
	
	local GIT_HOST
	local GIT_REPO
	local GIT_PROJECT
	local GIT_USER
	local GIT_PASSWD
	local ORIGINAL_BRANCH
	local NEW_BRANCH
	
	GIT_HOST="$1"
	#GIT_REPO="$2"
	GIT_PROJECT="$3"
	GIT_USER="$4"
	#GIT_PASSWD="$5"
	ORIGINAL_BRANCH="$6"
	NEW_BRANCH="$7"
	
	GIT_ORIGINAL_URL="https://$GIT_HOST/$GIT_USER/$GIT_PROJECT.git"
	
	if [[ "$NEW_BRANCH" != "" ]]; then
		GIT_CMD=$( which git )
		
		REMOTE_BRANCH_FOUND=$( git branch -r | grep "origin/$NEW_BRANCH" | xargs )
		if [[ ! -z "$REMOTE_BRANCH_FOUND" ]]; then  # if branch already exists
			#TODO: ???
			echo "PENDING IMPLEMENTATION!!!" && exit 1
		else
			echo "Create new local branch"
			$GIT_CMD branch "$NEW_BRANCH" || exit 1		
		fi
		
		
		echo "Go to new branch"
		$GIT_CMD checkout "$NEW_BRANCH" || exit 1

		echo "Commit staged changes to local master"
		$GIT_CMD add .  || exit 1
		$GIT_CMD commit -m "Test" -m "Creation new branch with name $NEW_BRANCH"  || exit 1
		
		echo "Push branch to remote"
		$GIT_CMD push -u "$GIT_ORIGINAL_URL" "$NEW_BRANCH"  || exit 1
		
		echo "Goto $ORIGINAL_BRANCH branch again"
		$GIT_CMD checkout "$ORIGINAL_BRANCH"  || exit 1
		
		echo "Fetch to local branch \"see\" new remote branch"
		$GIT_CMD fetch  || exit 1
	fi
}
