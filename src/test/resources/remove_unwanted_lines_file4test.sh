#!/usr/bin/env bash
#!/bin/bash

source ../../../bootstrap.sh

include_lib sh-unit

include_file "$SRC_DIR_PATH/shpm_evict_catastrophic_remove.sh"

include_file "$SRC_DIR_PATH/shpm_file_utils.sh"
include_file "$SRC_DIR_PATH/shpm_log_utils.sh"
include_file "$SRC_DIR_PATH/shpm_git_api.sh"

source "$ROOT_DIR_PATH/$DEPENDENCIES_FILENAME"

test123