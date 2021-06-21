
<h1 align="center">Welcome to the </h1>
<p align="center">
  <img src="https://raw.githubusercontent.com/sh-pm/sh-pm/master/doc/img/shpm-logo.png" />
</p>
<p align="center">The <b>SH</b>ell script <b>P</b>ackage <b>M</b>anager.</p>

## How to install in your project:

In folder containing you sh script, run code below in a terminal:

```
SHPM_LAST_VERSION="v4.0.0" && ACTUAL_DIR=$(pwd) && cd /tmp && rm -rf sh-pm-* || true && wget https://github.com/sh-pm/sh-pm/raw/master/releases/sh-pm-"$SHPM_LAST_VERSION".tar.gz  && tar -xvzf sh-pm-"$SHPM_LAST_VERSION".tar.gz && cd "$ACTUAL_DIR" && cp /tmp/sh-pm-"$SHPM_LAST_VERSION"/* . && rm -rf /tmp/sh-pm-* && ./shpm.sh update && ./shpm.sh init && cd src/main/sh
```

## How to reuse existing shell script code:

By use of *include_lib*'s in your *.sh file:

#### Example 1: Log's 
Supose you want use log's. 
Don't create code for this, because already exists log function's in dependency called **sh-logger**.
Let's go download and use it in your project:

1) Open *pom.sh* and insert dependency lib containg reusable code: 
```
declare -A DEPENDENCIES=( \
	[sh-logger]=v1.4.0@github.com/sh-pm \
);
```
OBS: In multiline command's don't put spaces before \ character: it will cause errors similar below:
```
(...)/pom.sh: line 5: DEPENDENCIES: \ : must use subscript when assigning associative array
```

2) Run shpm update to download dependency lib with reusable code from GitHub
```
$ ./shpm.sh update
```
The command will download and extract dependency to local sh-pm repository located in $ROOT_FOLDER_PATH/src/sh/lib

3) Include dependency lib in file(s) and use reusable code
Example:
```
#!/usr/bin/env bash
source ../../../bootstrap.sh

include_lib sh-logger
include_lib sh-commons

log_info "Hello World SH-PM: test show some informative log text" # log_info is a reusable function inside sh-logger lib
log_warn "Hello World SH-PM: test show some warning log text" # log_warn is a reusable function inside sh-logger lib

```

### Example 2: Ensure correct number of params
Supose you want force user to pass params to your script.
Don't create function's for this, because already exists a dependency called **sh-commons** containing many common utilitary functions.

1) Open *pom.sh* and insert dependency lib containg reusable code: 
```
declare -A DEPENDENCIES=( \
	[sh-logger]=v1.4.0@github.com/sh-pm \
	[sh-commons]=v2.2.3@github.com/sh-pm \
);
```
OBS: In multiline command's don't put spaces before \ character: it will cause errors similar below:
```
(...)/pom.sh: line 5: DEPENDENCIES: \ : must use subscript when assigning associative array
```

2) Run shpm update to download dependency lib with reusable code from GitHub
```
$ ./shpm.sh update
```
The command will download and extract dependency to local sh-pm repository located in $ROOT_FOLDER_PATH/src/sh/lib

3) Include dependency lib in file(s) and use reusable code
Example: Let's force user to pass exactly 1 param to script
```
#!/usr/bin/env bash
source ../../../bootstrap.sh

include_lib sh-logger
include_lib sh-commons

log_info "Test show some informative log text" # log_info is a reusable function inside sh-logger lib
log_warn "Test show some warning log text" # log_warn is a reusable function inside sh-logger lib

ensure_number_params_correct 1 $@

log_info "Content of param received: $1"

```


## Very Important!
### Only 1 version of each dependency per project! 
Even though several scripts refer to several different versions of the same lib, **only one version is used: the version that is in the project's _pom.sh_**.

**Reason**: if several different versions are loaded, and certain functions and / or variables exist in more than one version, the environment is only valid for what was defined in the last load. The definitions of variables and functions of previously loaded versions will be overwritten by the most recent uploads and this can cause unpredictable behavior.

### "Boolean values":
  * TRUE=0
  * FALSE=1

## Existing dependencies available

#### sh-logger
Log utilities inspired in log4j: <a href="https://github.com/sh-pm/sh-logger" target="_blank">https://github.com/sh-pm/sh-logger</a>

#### sh-unit
Functions to write and run unit tests of your project function's: <a href="https://github.com/sh-pm/sh-unit" target="_blank">https://github.com/sh-pm/sh-unit</a>

#### sh-commons
Common utilities for manipulation of date and time, string, IP, param validation and more: <a href="https://github.com/sh-pm/sh-commons" target="_blank">https://github.com/sh-pm/sh-commons</a>


## Install SH-PM manually

**Perform 5 steps:** 

#### Step 1 -  Download last version

Download the <b>last version</b> <a href="https://github.com/sh-pm/sh-pm/tree/master/releases" target="_blank">from GitHub</a>

#### Step 2 -  Extract 3 files to root folder

After download, extract the 3 files inside a **.tar.gz** to root folder of your project.
After this step, in your root folder will be add the 3 shell script files: 
 - **bootstrap.sh**: Create environment variables to help standardize path's;
 - **pom.sh**: identify your project and dependencies to be used;
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

SH-PM expects you to store scripts, tests and dependencies in separate folders. Perform a command:
```
$ ./shpm.sh init
```
It will create **src/main/sh** folder to store your scripts (_Your shell script code automatically will be moved to this folder_) and **src/test/sh** to store your tests. 

Finish: After the 5 steps, your project is ready to use dependencies downloaded!
