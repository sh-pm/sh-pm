## sh-pm
Shell Scripts Package Manager

<p align="center">
  <img src="https://raw.githubusercontent.com/sh-pm/sh-pm/master/doc/img/sh-pm-architecture.png" />
</p>

### How to install in your project

- <a href="https://github.com/sh-pm/sh-pm/blob/master/releases/" target="_blank">Download the last stable release</a>
- Extract to root folder of your project, the 3 files below 
  - **bootstrap.sh** 
  - **pom.sh**
  - **shpm.sh**

### How to reuse code

You can use functions inside dependencies by use "include's" in start of .sh file:
#### Example: 
Supose you go use log's, exists a dependency called **sh-logger**

1) Open pom.sh and insert dependency lib containg reusable code: 
```

(...)

declare -A DEPENDENCIES=( \
	[sh_logger]=v1.3.0 
);

(...)

```

2) Run shpm update to download dependency lib with reusable code from sh-archiva
```
$ ./shpm.sh update
```
The command will download and extract dependency to local sh-pm repository located in $ROOT_FOLDER_PATH/src/sh/lib

3) Include dependency lib in file(s) and use reusable code
Example:
```
#!/bin/bash
source ./bootstrap.sh

include_lib sh-logger

#YOUR SH CODE HERE
log_info "Work's fine!" # log_info is a reusable function inside sh-logger lib
```

### The three files of sh-pm:
#### bootstrap.sh
Create environment variables to help stardardize path's
  
#### pom.sh
Define: 
- Group and version of your script(s) application
- Dependencies to be downloaded via shpm for use in you script(s)

#### shpm.sh
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

# WARNING
## "Boolean values":
  * TRUE=0
  * FALSE=1

## Dependencies: 
Even though several scripts refer to several different versions of the same lib, **only one version is used: the version that is in the project's _pom.sh_**.

**Reason**: if several different versions are loaded, and certain functions and / or variables exist in more than one version, the environment is only valid for what was defined in the last load. The definitions of variables and functions of previously loaded versions will be overwritten by the most recent uploads and this can cause unpredictable behavior.
