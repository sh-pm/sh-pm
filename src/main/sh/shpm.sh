#!/bin/bash

source ../../../bootstrap.sh

# Evict catastrophic rm's
if [[ -z $ROOT_DIR_PATH ]]; then
	echo "bootstrap.sh file not loaded!"
	exit 1
fi

shpm_log() {
	echo "$1"
}

shpm_log_operation() {
    echo "================================================================"
	echo "sh-pm: $1"
	echo "================================================================"
}

print_help() {
  
    SCRIPT_NAME=shpm

	echo ""
	echo "USAGE:"
	echo "  shpm [OPTION]"
	echo ""
	echo "OPTIONS:"
    echo "  update                Download dependencies in local repository $LIB_DIR_SUBPATH"
	echo "  clean                 Clean $TARGET_DIR_PATH folder"
    echo "  test                  Run tests in $TEST_DIR_SUBPATH folder"
    echo "  build                 Create compressed file in $TARGET_DIR_PATH folder"
	echo "  install               Install in local repository $LIB_DIR_SUBPATH"            
    echo "  publish               Publish compressed sh in repository"
    echo "  autoupdate            Update itself"
	echo "  uninstall             Remove from local repository $LIB_DIR_SUBPATH"
	echo ""
	echo "EXAMPLES:"
	echo "  ./shpm update"
	echo ""
	echo "  ./shpm build"
	echo ""
	echo "  ./shpm build publish"
	echo ""
}

run_sh_pm() {

	local UPDATE=false
	local TEST=false
	local CLEAN=false
	local BUILD=false
	local INSTALL=false	
	local PUBLISH=false
	local AUTOUPDATE=false
	local UNINSTALL=false
	
	if [ $# -eq 0 ];  then
		print_help
		exit 1
	else
		for (( i=1; i <= $#; i++)); do	
	        ARG="${!i}"
	
			if [[ "$ARG" == "update" ]];  then
				UPDATE="true"
			fi

			if [[ "$ARG" == "test" ]];  then
				TEST="true"
			fi
			
			if [[ "$ARG" == "clean" ]];  then
				CLEAN="true"
			fi
		
			if [[ "$ARG" == "build" ]];  then
				BUILD="true"
			fi
			
			if [[ "$ARG" == "install" ]];  then
				INSTALL="true"
			fi
			
			if [[ "$ARG" == "publish" ]];  then
				PUBLISH="true"
			fi
			
			if [[ "$ARG" == "autoupdate" ]];  then
				AUTOUPDATE="true"
			fi
			
			if [[ "$ARG" == "uninstall" ]];  then
				UNINSTALL="true"
			fi
		done
	fi
	
	
	if [[ "$UPDATE" == "true" ]];  then
		update_dependencies	
	fi
	
	if [[ "$CLEAN" == "true" ]];  then
		clean_release
	fi
	
	if [[ "$TEST" == "true" ]];  then
		run_all_tests
	fi
	
	if [[ "$BUILD" == "true" ]];  then
		build_release
	fi
	
	if [[ "$INSTALL" == "true" ]];  then
		install_release
	fi
	
	if [[ "$PUBLISH" == "true" ]];  then	
		publish_release
	fi
	
	if [[ "$AUTOUPDATE" == "true" ]];  then	
		auto_update
	fi
	
	if [[ "$UNINSTALL" == "true" ]];  then
		uninstall_release
	fi	
}

clean_release() {

	shpm_log_operation "Cleaning release"
	
	if [[ ! -z "$TARGET_DIR_PATH" && -d "$TARGET_DIR_PATH" ]]; then
	
		shpm_log "Removing *.tar.gz files from $TARGET_DIR_PATH ..."
		
		cd "$TARGET_DIR_PATH"
		rm *.tar.gz 2> /dev/null
		
		shpm_log "Done"
	else
		shpm_log "ERROR: $TARGET_DIR_PATH not found."
	fi
}

update_dependencies() {

	shpm_log_operation "Update Dependencies"

	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}
	
	shpm_log "Start update of ${#DEPENDENCIES[@]} dependencies ..."
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
		update_dependency $DEP_ARTIFACT_ID
	done
	
	cd $ROOT_DIR_PATH
	
	shpm_log "Done"
}

uninstall_release () {

	clean_release
	build_release
	
	shpm_log_operation "Uninstall lib"
	
	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local TGZ_FILE=$TARGET_FOLDER".tar.gz"
	local TGZ_FILE_PATH=$TARGET_DIR_PATH/$TGZ_FILE
	
	local ACTUAL_DIR=$(pwd)
	
	shpm_log "Removing old *.tar.gz files from $LIB_DIR_PATH ..."
	cd $LIB_DIR_PATH/
	rm *".tar.gz" 2> /dev/null	
	
	shpm_log "Move lib $LIB_DIR_PATH/$TARGET_FOLDER to /tmp folder ..."
	if [[ -d  $LIB_DIR_PATH/$TARGET_FOLDER ]]; then
		# evict rm -rf!
		mv $LIB_DIR_PATH/$TARGET_FOLDER /tmp 2> /dev/null
		local TIMESTAMP=$( date +"%Y%m%d_%H%M%S_%N" )			
		mv /tmp/$TARGET_FOLDER /tmp/$TARGET_FOLDER"_"$TIMESTAMP
	fi	
	
	cd "$ACTUAL_DIR"
	
	shpm_log "Done"
}

install_release () {

	clean_release
	build_release
	uninstall_release
	
	shpm_log_operation "Install Release into local repository"
	
	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local TGZ_FILE=$TARGET_FOLDER".tar.gz"
	local TGZ_FILE_PATH=$TARGET_DIR_PATH/$TGZ_FILE
	
	local ACTUAL_DIR=$(pwd)
	
	shpm_log "Install $TGZ_FILE_PATH into $LIB_DIR_PATH ..."
	cd $LIB_DIR_PATH/
	
	cp $TGZ_FILE_PATH $LIB_DIR_PATH/	
	
	tar -xzf $TGZ_FILE
		
	rm -f $TGZ_FILE
	
	cd "$ACTUAL_DIR"
	
	shpm_log "Done"
}

update_dependency() {

        local DEP_ARTIFACT_ID=$1
		local DEP_VERSION="${DEPENDENCIES[$DEP_ARTIFACT_ID]}"
				
		shpm_log "----------------------------------------------------"
		shpm_log "  Update $DEP_ARTIFACT_ID to $DEP_VERSION: Start"
		
		if [[ ! -d $LIB_DIR_PATH ]]; then
		  mkdir -p $LIB_DIR_PATH
		fi
		
		local DEP_FOLDER_NAME=$DEP_ARTIFACT_ID"-"$DEP_VERSION
		local DEP_FILENAME=$DEP_FOLDER_NAME".tar.gz"
		
		shpm_log "   - Downloading $DEP_FILENAME ..."
		curl -s  http://$HOST:$PORT/sh-archiva/get/snapshot/$GROUP_ID/$DEP_ARTIFACT_ID/$DEP_VERSION > $LIB_DIR_PATH/$DEP_FILENAME 
		
		cd $LIB_DIR_PATH/
		
		shpm_log "   - Extracting $DEP_FILENAME into $LIB_DIR_PATH/$DEP_FOLDER_NAME ..."
		if [[ -d  $LIB_DIR_PATH/$DEP_ARTIFACT_ID ]]; then
			# evict rm -rf!
			mv $LIB_DIR_PATH/$DEP_ARTIFACT_ID /tmp 2> /dev/null
			local TIMESTAMP=$( date +"%Y%m%d_%H%M%S_%N" )			
			mv /tmp/$DEP_ARTIFACT_ID /tmp/$DEP_ARTIFACT_ID"_"$TIMESTAMP
		fi
		
		tar -xzf $DEP_FILENAME
		
		rm -f $DEP_FILENAME
		
		# if update a sh-pm
		if [[ "$DEP_ARTIFACT_ID" == "sh-pm" ]]; then
		
        	if [[ ! -d $ROOT_DIR_PATH/tmpoldshpm ]]; then
	        	mkdir $ROOT_DIR_PATH/tmpoldshpm		
			fi
	        
	        shpm_log "     WARN: sh-pm updating itself ..."
	        
	        if [[ -f $ROOT_DIR_PATH/shpm.sh ]]; then
	        	shpm_log "   - backup actual sh-pm version to $ROOT_DIR_PATH/tmpoldshpm ..."
	        	mv $ROOT_DIR_PATH/shpm.sh $ROOT_DIR_PATH/tmpoldshpm
	        fi
	        
	        if [[ -f $LIB_DIR_PATH/$DEP_FOLDER_NAME/shpm.sh ]]; then
	        	shpm_log "   - update shpm.sh ..."
	        	cp $LIB_DIR_PATH/$DEP_FOLDER_NAME/shpm.sh	$ROOT_DIR_PATH
	        fi
	        
	        if [[ -f $ROOT_DIR_PATH/$BOOTSTRAP_FILENAME ]]; then
	        	shpm_log "   - backup actual $BOOTSTRAP_FILENAME to $ROOT_DIR_PATH/tmpoldshpm ..."
	        	mv $ROOT_DIR_PATH/$BOOTSTRAP_FILENAME $ROOT_DIR_PATH/tmpoldshpm
	        fi
	        
	        if [[ -f $LIB_DIR_PATH/$DEP_FOLDER_NAME/$BOOTSTRAP_FILENAME ]]; then
	        	shpm_log "   - update $BOOTSTRAP_FILENAME ..."
	        	cp $LIB_DIR_PATH/$DEP_FOLDER_NAME/$BOOTSTRAP_FILENAME	$ROOT_DIR_PATH
	        fi
		fi
		
		shpm_log "  Update $DEP_ARTIFACT_ID to $DEP_VERSION: Finish"
}

build_release() {

	run_all_tests
	
	# Verify if are unit test failures
	if [ ! -z ${TEST_STATUS+x} ]; then
		if [[ "$TEST_STATUS" != "OK" ]]; then
			shpm_log "Unit Test's failed!"
			exit 1; 
		fi
	fi

	shpm_log_operation "Build Release"

	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	

	shpm_log "Remove $TARGET_DIR_PATH folder ..."
	rm -rf ./target
	
	TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	
	if [[ ! -d $TARGET_DIR_PATH/$TARGET_FOLDER ]]; then
		mkdir -p $TARGET_DIR_PATH/$TARGET_FOLDER 
	fi

	shpm_log "Coping .sh files from $SRC_DIR_PATH/* to $TARGET_DIR_PATH/$TARGET_FOLDER ..."
	cp -R $SRC_DIR_PATH/* $TARGET_DIR_PATH/$TARGET_FOLDER
	
	# if not build itself
	if [[ ! -f $SRC_DIR_PATH/"shpm.sh" ]]; then
		shpm_log "Coping pom.sh ..."
		cp $ROOT_DIR_PATH/pom.sh $TARGET_DIR_PATH/$TARGET_FOLDER
	else 
		shpm_log "Creating pom.sh ..."
	    cp $SRC_DIR_PATH/../resources/template_pom.sh $TARGET_DIR_PATH/$TARGET_FOLDER/pom.sh
	    
	    shpm_log "Coping bootstrap.sh ..."
    	cp $ROOT_DIR_PATH/bootstrap.sh $TARGET_DIR_PATH/$TARGET_FOLDER
	fi
	
	shpm_log "Add sh-pm comments in .sh files ..."
	cd $TARGET_DIR_PATH/$TARGET_FOLDER	
	sed -i 's/\#\!\/bin\/bash/\#\!\/bin\/bash\n# '$VERSION' - Build with sh-pm/g' *.sh
		
	# if not build itself
	if [[ ! -f $TARGET_DIR_PATH/$TARGET_FOLDER/"shpm.sh" ]]; then
		shpm_log "Removing bootstrap.sh sourcing command from .sh files ..."
		sed -i 's/source \.\/bootstrap.sh//g' *.sh		
		sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh//g' *.sh
	else
		shpm_log "Update bootstrap.sh sourcing command from .sh files ..."
	   	sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh/source \.\/bootstrap.sh/g' shpm.sh	   	
	fi
	
	shpm_log "Package: Compacting .sh files ..."
	cd $TARGET_DIR_PATH	
	tar -czf $TARGET_FOLDER".tar.gz" $TARGET_FOLDER
	
	if [[ -d $TARGET_DIR_PATH/$TARGET_FOLDER ]]; then
		rm -rf $TARGET_DIR_PATH/$TARGET_FOLDER	
	fi
	
	shpm_log "Relese file generated in folder $TARGET_DIR_PATH"
	
	cd $ROOT_DIR_PATH
	
	shpm_log "Done"
}

publish_release() {

	if [[ "$SSO_API_AUTHENTICATION_URL" == "" ]]; then
		shpm_log "In order to publish release, you must define SSO_API_AUTHENTICATION_URL variable in your pom.sh."
		exit 1
	fi

	clean_release
	
	build_release

	shpm_log_operation "Starting publish release process"
	 
	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	

	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local TGZ_FILE_NAME=$TARGET_FOLDER".tar.gz"
	local FILE_PATH=$TARGET_DIR_PATH/$TGZ_FILE_NAME
	
	local TARGET_REPO="https://$HOST:$PORT/sh-archiva/snapshot/$GROUP_ID/$ARTIFACT_ID/$VERSION"
	shpm_log "----------------------------------------------------------------------------"
	shpm_log "From: $FILE_PATH"
	shpm_log "  To: $TARGET_REPO"
	shpm_log "----------------------------------------------------------------------------"
	
	echo Username:
	read USERNAME
	
	echo Password:
	read -s PASSWORD
	
	shpm_log "Authenticating user \"$USERNAME\" in $SSO_API_AUTHENTICATION_URL ..."
	#echo "curl -s -X POST -d '{\"username\" : \"'$USERNAME'\", \"password\": \"'$PASSWORD'\"}' -H 'Content-Type: application/json' $SSO_API_AUTHENTICATION_URL"	
	TOKEN=$( curl -s -X POST -d '{"username" : "'$USERNAME'", "password": "'$PASSWORD'"}' -H 'Content-Type: application/json' $SSO_API_AUTHENTICATION_URL )
	
	if [[ "$TOKEN" == "" ]]; then
		shpm_log "Authentication failed"
		exit 2
	else
		shpm_log "Authentication successfull"
		shpm_log "Sending release to repository ..."
		TOKEN_HEADER="Authorization: Bearer $TOKEN"	
		MSG_RETURNED=$( curl -s -F file=@"$FILE_PATH" -H "$TOKEN_HEADER" $TARGET_REPO )
		shpm_log "Sended"
		
		shpm_log "Return received from repository:"
		shpm_log "----------------------------------------------------------------------------"
		shpm_log "$MSG_RETURNED"
		shpm_log "----------------------------------------------------------------------------"
		
		shpm_log "Done"
	fi 
}

run_all_tests() {

	shpm_log_operation "Searching unit test files to run ..."

	local ACTUAL_DIR=$(pwd)

	cd $TEST_DIR_PATH
	
	local TEST_FILES=( $(ls *_test.sh 2> /dev/null) );
	
	shpm_log "Found ${#TEST_FILES[@]} test files" 
	if (( ${#TEST_FILES[@]} > 0 )); then
		for file in ${TEST_FILES[@]}
		do
			shpm_log "Run file ..."
			source $file
		done
	else
		shpm_log "Nothing to test"
	fi
	
	cd $ACTUAL_DIR
	shpm_log "Done"
}

auto_update() {

	shpm_log_operation "Running sh-pm auto update ..."
	 
    local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	
	
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
	    if [[ "$DEP_ARTIFACT_ID" == "sh-pm" ]]; then		
			update_dependency $DEP_ARTIFACT_ID
			
			shpm_log "Done"
	        exit 0    
	    fi
	done
	
	shpm_log "Could not update sh-pm: sh-pm not present in dependencies of pom.sh"
	exit 1004
}


run_sh_pm $@
