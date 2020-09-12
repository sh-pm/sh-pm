#!/bin/bash

source ../../../bootstrap.sh  

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
    echo "  autoupdate            Update itself"
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
	local AUTOUPDATE=false
	
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
			
			if [[ "$ARG" == "autoupdate" ]];  then
				AUTOUPDATE="true"
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
	
	if [[ "$AUTOUPDATE" == "true" ]];  then	
		auto_update
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

update_dependency() {

        local DEP_ARTIFACT_ID=$1

		DEP_VERSION="${DEPENDENCIES[$DEP_ARTIFACT_ID]}"		
		
		if [[ ! -d $LIB_DIR_PATH ]]; then
		  mkdir -p $LIB_DIR_PATH
		fi
		
		DEP_FILENAME=$DEP_ARTIFACT_ID"-"$DEP_VERSION".tar.gz"
		
		echo "http://$HOST:$PORT/sh-archiva/get/snapshot/$GROUP_ID/$DEP_ARTIFACT_ID/$DEP_VERSION > $LIB_DIR_PATH/$DEP_FILENAME"
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
		
		# if update a sh-pm
		if [[ "$DEP_ARTIFACT_ID" == "sh-pm" ]]; then
	        
	        if [[ -f $ROOT_DIR_PATH/shpm.sh ]]; then
	        	if [[ ! -d $ROOT_DIR_PATH/tmpoldshpm ]]; then
		        	mkdir $ROOT_DIR_PATH/tmpoldshpm		
				fi
	        	mv $ROOT_DIR_PATH/shpm.sh $ROOT_DIR_PATH/tmpoldshpm
	        fi
	        
	        TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	        cp $LIB_DIR_PATH/$TARGET_FOLDER/shpm.sh	$ROOT_DIR_PATH
		fi

}

build_release() {

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
	fi
	
	cd $TARGET_DIR_PATH
	cp $ROOT_DIR_PATH/bootstrap.sh $TARGET_DIR_PATH/$TARGET_FOLDER
	
	tar -cvzf $TARGET_FOLDER".tar.gz" $TARGET_FOLDER
	
	if [[ -d $TARGET_DIR_PATH/$TARGET_FOLDER ]]; then
		rm -rf $TARGET_DIR_PATH/$TARGET_FOLDER	
	fi
	
	cd $ROOT_DIR_PATH

}

publish_release() {

	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	

	TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	FILE_PATH=$TARGET_DIR_PATH/$TARGET_FOLDER".tar.gz" 
	
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

auto_update() {

    local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	
	
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
	
	    if [[ "$DEP_ARTIFACT_ID" == "sh-pm" ]]; then		
			
			echo "Updating sh-pm ..."
			
			update_dependency $DEP_ARTIFACT_ID
	        
	        if [[ ! -d $ROOT_DIR_PATH/tmpoldshpm ]]; then
		        mkdir $ROOT_DIR_PATH/tmpoldshpm		
			fi
	        mv $ROOT_DIR_PATH/shpm.sh $ROOT_DIR_PATH/tmpoldshpm
	        
	        TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	        cp $LIB_DIR_PATH/$TARGET_FOLDER/shpm.sh	$ROOT_DIR_PATH
	        
	        exit 0    
	    fi
	done
	
	echo "Could not update sh-pm: sh-pm not present in dependencies of pom.sh"
	exit 1
}


run_sh_pm $@