# sh-pm
Shell Scripts Package Manager

## Install in your project

- Go to sh-pm site
- Download sh-pm tar.gz
- Extract files below to root folder of your project
  - **bootstrap.sh** 
  - **pom.sh**
  - **shpm.sh**
  
## The three files:
### bootstrap.sh
Create environment variables to help stardardize path's
  
### pom.sh
Define: 
- Group and version of your script(s) application
- Dependencies to be downloaded via shpm for use in you script(s)

### shpm.sh
The shell script package manager "executable"

## Expected folder structure
shpm expected a folder structure to be create to organize your script(s)
```
your_project_folder
   \src
      \main
         \lib
      \sh
         your_script1.sh
         your_script2.sh
         your_script3.sh
         \subfolder
            your_script4.sh
            your_script5.sh
         ...
         your_scriptN.sh
      \resources
  
   \target
      your_project_folder-VERSION.tar.gz
   pom.sh
   shpm.sh
   bootstrap.sh
```

## How to use functions in dependencies

You can use functions inside dependencies with "include's" in start of .sh file:
Ex: if you go use log's, exist's a dependency called **sh-logger**

1) Open pom.sh and insert dependency: 
```

(...)

declare -A DEPENDENCIES=( \
	[sh_logger]=v1.2.0 
);

(...)

```

2) Run shpm update to download dependency from sh-archiva
```
$ ./shpm.sh update
```
The command will download and extract dependency to local sh-pm repository located in $ROOT_FOLDER_PATH/src/sh/lib

3) Include dependency in file(s)

```
#!/bin/bash

source ../../../bootstrap.sh                           #<-------- MANDATORY INCLUDE

source $LIB_DIR_PATH/sh_logger/sh_logger.sh            #
source $LIB_DIR_PATH/sh_commons/shell_util.sh          # <------- THIS IS "INCLUDE's" OF DEPENDENCIES FILES
source $LIB_DIR_PATH/sh_boolean_utils/boolean_util.sh  #

#------------
YOUR SH CODE HERE
#------------

```
