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
