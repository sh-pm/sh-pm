<p align="center">
Welcome to the <b>SH-PM</b>: the <b>SH</b>ell script <b>P</b>ackage <b>M</b>anager. 
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/sh-pm/sh-pm/master/doc/img/shpm-logo.png" />
</p>

### How to install in your project

<a href="https://www.youtube.com/embed/NET9aLS3K-A" target="_blank">See in this video</a>

To quickly install and start use it in your project, you have perform only 5 steps: 

#### Step 1 -  Download from shpmcenter

Using your browser, access <a href="https://shpmcenter.com" target="_blank">shpmcenter.com</a> and download the last version

#### Step 2 -  Extract to root folder

After download, extract the 3 files inside a **.tar.gz** to root folder of your project.
After this step, in your root folder will be add the 3 shell script files: 
 - **bootstrap.sh**: Create environment variables to help stardardize path's;
 - **pom.sh**: identify your project and dependencies to be downloaded to use;
 - **shpm.sh**: is SH-PM itself.

#### Step 3 – Name your project

Open shell script file pom.sh and inform in **ARTIFACT_ID** the name of your project. 
This file contain all dependencies to be used in your project.

#### Step 4 – Update dependencies

Using a terminal, inside root folder of your project, perform a command 
```
  $ ./shpm.sh update
```
The package manager will download all version of dependencies informed in pom.sh to **src/lib/sh** folder. 
After update, dependencies will be available for use in your shell scripts.

#### Step 5 – Init expected structure

SH-PM expects you to store scripts, unit tests and dependencies in separate folders. Perform a command:
```
$ ./shpm.sh init
```
It will create **src/main/sh** folder to store your scripts (_Your shell script code automatically will be moved to this folder_) and **src/test.sh** to store your unit tests. 

Finish: After the 5 steps, your project, is ready to use dependencies downloaded!

# WARNING
## "Boolean values":
  * TRUE=0
  * FALSE=1

## Dependencies: 
Even though several scripts refer to several different versions of the same lib, **only one version is used: the version that is in the project's _pom.sh_**.

**Reason**: if several different versions are loaded, and certain functions and / or variables exist in more than one version, the environment is only valid for what was defined in the last load. The definitions of variables and functions of previously loaded versions will be overwritten by the most recent uploads and this can cause unpredictable behavior.

### Existing libraries
<p align="center">
  <img src="https://raw.githubusercontent.com/sh-pm/sh-pm/master/doc/img/shpm-components.png" />
</p>

#### sh-logger
Log utilities inspired in log4j

#### sh-unit
Functions to write and run unit tests of your project function's

#### sh-commons
##### date_time_utils.sh
- Get timestamp's to add in string or filenames

##### log_utils.sh
- Print delimiters and script help

##### net_utils.sh
- Get local IP

##### string_utils.sh
string_start_with
string_end_with
string_contains

##### validation_utils.sh
- Many function to aux do script validation's: check number of params, if is a folder or file ... etc

### How to use existing .sh libraries

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
