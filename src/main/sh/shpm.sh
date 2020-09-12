#!/bin/bash

source ./bootstrap.sh  

source $ROOT_DIR_PATH/pom.sh

BOOTSTRAP_FILENAME="bootstrap.sh"

print_help() {
  
    SCRIPT_NAME=shpm

	echo ""
	echo "USAGE:"
	echo "  shpm [OPTION]"
	echo ""
	echo "OPTIONS:"
    echo "  update                Download dependencies in $LIB_DIR_SUBPATH folder"
    echo "  test                  Run tests in $TEST_DIR_SUBPATH folder"
    echo "  build                 Create compressed file in $TARGET_DIR_PATH folder"        
    echo "  publish               Publish compressed sh in repository"
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
	local BUILD=false
	local PUBLISH=false
	
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
		
			if [[ "$ARG" == "build" ]];  then
				BUILD="true"
			fi
			
			if [[ "$ARG" == "publish" ]];  then
				PUBLISH="true"
			fi		
		done
	fi
	
	
	if [[ "$UPDATE" == "true" ]];  then
		update_dependencies	
	fi
	
	if [[ "$BUILD" == "true" ]];  then
		build_release
	fi
	
	if [[ "$TEST" == "true" ]];  then
		run_all_tests
	fi
	
	if [[ "$PUBLISH" == "true" ]];  then	
		publish_release
	fi
}

update_dependencies() {

	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	
			
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
	
		DEP_VERSION="${DEPENDENCIES[$DEP_ARTIFACT_ID]}"		
		
		if [[ ! -d $LIB_DIR_PATH ]]; then
		  mkdir -p $LIB_DIR_PATH
		fi
		
		DEP_FILENAME=$DEP_ARTIFACT_ID".tar.gz"
		
		echo "curl  http://$HOST:$PORT/sh-archiva/get/snapshot/$GROUP_ID/$DEP_ARTIFACT_ID/$DEP_VERSION"
		curl  http://$HOST:$PORT/sh-archiva/get/snapshot/$GROUP_ID/$DEP_ARTIFACT_ID/$DEP_VERSION > $LIB_DIR_PATH/$DEP_FILENAME
		
		cd $LIB_DIR_PATH/
		
		if [[ -d  $LIB_DIR_PATH/$DEP_ARTIFACT_ID ]]; then
			# evict rm -rf!
			mv $LIB_DIR_PATH/$DEP_ARTIFACT_ID /tmp 2> /dev/null
			local TIMESTAMP=$( date +"%Y%m%d_%H%M%S_%N" )			
			mv /tmp/$DEP_ARTIFACT_ID /tmp/$DEP_ARTIFACT_ID"_"$TIMESTAMP
		fi
		
		tar -xvzf $DEP_FILENAME
		
		rm -f $DEP_FILENAME
		
	done
	
	cd $ROOT_DIR_PATH

}

build_release() {

	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	

	rm -rf ./target
	
	if [[ ! -d $TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID ]]; then
		mkdir -p $TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID 
	fi
	
	cp -R $SRC_DIR_PATH/* $TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID
	
	# if not build itself
	if [[ ! -f $TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID/"shpm.sh" ]]; then
		cp $ROOT_DIR_PATH/pom.sh $TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID
	else 
	    cp $SRC_DIR_PATH/../resources/template_pom.sh $TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID/pom.sh
	fi
	
	cd $TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID
	
	sed -i 's/\#\!\/bin\/bash/\#\!\/bin\/bash\n# '$VERSION' - Build with shpm/g' *.sh
		
	# if not build itself
	if [[ ! -f $TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID/"shpm.sh" ]]; then
		rm $BOOTSTRAP_FILENAME
		sed -i 's/source \.\/bootstrap.sh//g' *.sh		
		sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh//g' *.sh	
	fi
	 	
	
	cd $TARGET_DIR_PATH/$VERSION
	
	tar -cvzf $ARTIFACT_ID".tar.gz" $ARTIFACT_ID
	
	cd $ROOT_DIR_PATH

}

publish_release() {

	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	

	FILE_PATH=$TARGET_DIR_PATH/$VERSION/$ARTIFACT_ID".tar.gz" 
	
	curl -F file=@"$FILE_PATH" http://$HOST:$PORT/sh-archiva/snapshot/$GROUP_ID/$ARTIFACT_ID/$VERSION
}

run_all_tests() {
	cd $TEST_DIR_PATH
	
	for file in `ls *_test.sh`
	do
		source $file
	done
	
	cd $ROOT_DIR_PATH
}


run_sh_pm $@