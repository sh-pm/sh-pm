## sh-pm
Shell Scripts Package Manager

<p align="center">
  <img src="https://raw.githubusercontent.com/sh-pm/sh-pm/master/doc/img/sh-pm-architecture.png" />
</p>

### How to install in your project

- Download sh-pm tar.gz
- Extract files below to root folder of your project
  - **bootstrap.sh** 
  - **pom.sh**
  - **shpm.sh**

### How to use functions in dependencies

You can use functions inside dependencies with "include's" in start of .sh file:
Example: Supose you go use log's, exists a dependency called **sh-logger**

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
Example:
```
#!/bin/bash
source ./bootstrap.sh

source $LIB_DIR_PATH/sh_logger/sh_logger.sh            

#YOUR SH CODE HERE
log_info "Work's fine!"
```

### The three files of sh-pm:
* bootstrap.sh
Create environment variables to help stardardize path's
  
* pom.sh
Define: 
- Group and version of your script(s) application
- Dependencies to be downloaded via shpm for use in you script(s)

* shpm.sh
The shell script package manager "executable"

### Expected folder structure
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
