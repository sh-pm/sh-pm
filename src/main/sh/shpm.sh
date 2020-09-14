#!/bin/bash

source ../../../bootstrap.sh

shpm_log() {
	echo "$1"
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
	if [[ ! -z "$TARGET_DIR_PATH" && -d "$TARGET_DIR_PATH" ]]; then
		cd "$TARGET_DIR_PATH"
		rm *.tar.gz 2> /dev/null
	fi
}

update_dependencies() {
	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}
	
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
		update_dependency $DEP_ARTIFACT_ID
	done
	
	cd $ROOT_DIR_PATH
}

uninstall_release () {

	clean_release
	build_release
	
	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local TGZ_FILE=$TARGET_FOLDER".tar.gz"
	local TGZ_FILE_PATH=$TARGET_DIR_PATH/$TGZ_FILE
	
	local ACTUAL_DIR=$(pwd)
	
	cd $LIB_DIR_PATH/
	rm *".tar.gz" 2> /dev/null	
	
	if [[ -d  $LIB_DIR_PATH/$TARGET_FOLDER ]]; then
		# evict rm -rf!
		mv $LIB_DIR_PATH/$TARGET_FOLDER /tmp 2> /dev/null
		local TIMESTAMP=$( date +"%Y%m%d_%H%M%S_%N" )			
		mv /tmp/$TARGET_FOLDER /tmp/$TARGET_FOLDER"_"$TIMESTAMP
	fi	
	
	cd "$ACTUAL_DIR"
}

install_release () {

	clean_release
	build_release
	uninstall_release
	
	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local TGZ_FILE=$TARGET_FOLDER".tar.gz"
	local TGZ_FILE_PATH=$TARGET_DIR_PATH/$TGZ_FILE
	
	local ACTUAL_DIR=$(pwd)
	
	cd $LIB_DIR_PATH/
	
	cp $TGZ_FILE_PATH $LIB_DIR_PATH/	
	
	tar -xzf $TGZ_FILE
		
	rm -f $TGZ_FILE
	
	cd "$ACTUAL_DIR"
}

update_dependency() {

        local DEP_ARTIFACT_ID=$1
		local DEP_VERSION="${DEPENDENCIES[$DEP_ARTIFACT_ID]}"
				
		shpm_log "Update $DEP_ARTIFACT_ID to $DEP_VERSION: Start"
		
		if [[ ! -d $LIB_DIR_PATH ]]; then
		  mkdir -p $LIB_DIR_PATH
		fi
		
		local DEP_FOLDER_NAME=$DEP_ARTIFACT_ID"-"$DEP_VERSION
		local DEP_FILENAME=$DEP_FOLDER_NAME".tar.gz"
		
		shpm_log " - Downloading $DEP_FILENAME ..."
		curl -s  http://$HOST:$PORT/sh-archiva/get/snapshot/$GROUP_ID/$DEP_ARTIFACT_ID/$DEP_VERSION > $LIB_DIR_PATH/$DEP_FILENAME 
		
		cd $LIB_DIR_PATH/
		
		shpm_log " - Extracting $DEP_FILENAME into $LIB_DIR_PATH/$DEP_FOLDER_NAME ..."
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
	        
	        shpm_log "   WARN: sh-pm updating itself ..."
	        
	        if [[ -f $ROOT_DIR_PATH/shpm.sh ]]; then
	        	shpm_log " - backup actual sh-pm version to $ROOT_DIR_PATH/tmpoldshpm ..."
	        	mv $ROOT_DIR_PATH/shpm.sh $ROOT_DIR_PATH/tmpoldshpm
	        fi
	        
	        if [[ -f $LIB_DIR_PATH/$DEP_FOLDER_NAME/shpm.sh ]]; then
	        	shpm_log " - update shpm.sh ..."
	        	cp $LIB_DIR_PATH/$DEP_FOLDER_NAME/shpm.sh	$ROOT_DIR_PATH
	        fi
	        
	        if [[ -f $ROOT_DIR_PATH/$BOOTSTRAP_FILENAME ]]; then
	        	shpm_log " - backup actual $BOOTSTRAP_FILENAME to $ROOT_DIR_PATH/tmpoldshpm ..."
	        	mv $ROOT_DIR_PATH/$BOOTSTRAP_FILENAME $ROOT_DIR_PATH/tmpoldshpm
	        fi
	        
	        if [[ -f $LIB_DIR_PATH/$DEP_FOLDER_NAME/$BOOTSTRAP_FILENAME ]]; then
	        	shpm_log " - update $BOOTSTRAP_FILENAME ..."
	        	cp $LIB_DIR_PATH/$DEP_FOLDER_NAME/$BOOTSTRAP_FILENAME	$ROOT_DIR_PATH
	        fi
		fi
		
		shpm_log "Update $DEP_ARTIFACT_ID to $DEP_VERSION: Finish"
}

build_release() {

	run_all_tests

	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	

	rm -rf ./target
	
	TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	
	if [[ ! -d $TARGET_DIR_PATH/$TARGET_FOLDER ]]; then
		mkdir -p $TARGET_DIR_PATH/$TARGET_FOLDER 
	fi

	cp -R $SRC_DIR_PATH/* $TARGET_DIR_PATH/$TARGET_FOLDER
	
	# if not build itself
	if [[ ! -f $TARGET_DIR_PATH/$TARGET_FOLDER/"shpm.sh" ]]; then
		cp $ROOT_DIR_PATH/pom.sh $TARGET_DIR_PATH/$TARGET_FOLDER
	else 
	    cp $SRC_DIR_PATH/../resources/template_pom.sh $TARGET_DIR_PATH/$TARGET_FOLDER/pom.sh
	fi
	
	cd $TARGET_DIR_PATH
	cp $ROOT_DIR_PATH/bootstrap.sh $TARGET_DIR_PATH/$TARGET_FOLDER
	
	cd $TARGET_DIR_PATH/$TARGET_FOLDER
	
	sed -i 's/\#\!\/bin\/bash/\#\!\/bin\/bash\n# '$VERSION' - Build with sh-pm/g' *.sh
		
	# if not build itself
	if [[ ! -f $TARGET_DIR_PATH/$TARGET_FOLDER/"shpm.sh" ]]; then
		sed -i 's/source \.\/bootstrap.sh//g' *.sh		
		sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh//g' *.sh
	else
	   	sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh/source \.\/bootstrap.sh/g' shpm.sh
	   	
	   	cd $ROOT_DIR_PATH
	   	sed -i 's/\#\!\/bin\/bash/\#\!\/bin\/bash\n# '$VERSION' - Build with sh-pm/g' *.sh
	fi
	
	cd $TARGET_DIR_PATH
	cp $ROOT_DIR_PATH/bootstrap.sh $TARGET_DIR_PATH/$TARGET_FOLDER
	
	tar -czf $TARGET_FOLDER".tar.gz" $TARGET_FOLDER
	
	if [[ -d $TARGET_DIR_PATH/$TARGET_FOLDER ]]; then
		rm -rf $TARGET_DIR_PATH/$TARGET_FOLDER	
	fi
	
	cd $ROOT_DIR_PATH

}

publish_release() {

	clean_release
	build_release

	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	

	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local FILE_PATH=$TARGET_DIR_PATH/$TARGET_FOLDER".tar.gz" 
	
	curl -F file=@"$FILE_PATH" http://$HOST:$PORT/sh-archiva/snapshot/$GROUP_ID/$ARTIFACT_ID/$VERSION
}

run_all_tests() {

	local ACTUAL_DIR=$(pwd)

	cd $TEST_DIR_PATH
	
	local TEST_FILES=( $(ls *_test.sh 2> /dev/null) );
	
	for file in ${TEST_FILES[@]}
	do
		source $file
	done
	
	cd $ACTUAL_DIR
}

auto_update() {

    local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	
	
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
	    if [[ "$DEP_ARTIFACT_ID" == "sh-pm" ]]; then		
			update_dependency $DEP_ARTIFACT_ID
	        exit 0    
	    fi
	done
	
	echo "Could not update sh-pm: sh-pm not present in dependencies of pom.sh"
	exit 1004
}


run_sh_pm $@