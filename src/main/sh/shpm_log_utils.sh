
export SHPM_LOG_DISABLED="$FALSE"

export G_SHPMLOG_TAB="  "
export G_SHPMLOG_INDENT=""

increase_g_indent() {
	G_SHPMLOG_INDENT="$G_SHPMLOG_INDENT""$G_SHPMLOG_TAB"
}

decrease_g_indent() {
	local END_POS
	END_POS=$( echo "${#G_SHPMLOG_INDENT} - ${#G_SHPMLOG_TAB}" | bc )
	G_SHPMLOG_INDENT="${G_SHPMLOG_INDENT:0:$END_POS}"
}

reset_g_indent() {
	G_SHPMLOG_INDENT=""
}

set_g_indent() {
	G_SHPMLOG_INDENT="$1"
}

shpm_log() {
	local MSG=$1
	local COLOR=$2
	
    if [[ "$SHPM_LOG_DISABLED" != "$TRUE" ]]; then
		if [[ "$COLOR" == "red" ]]; then
			echo -e "${G_SHPMLOG_INDENT}${ECHO_COLOR_RED}$MSG${ECHO_COLOR_NC}"			
		elif [[ "$COLOR" == "green" ]]; then
			echo -e "${G_SHPMLOG_INDENT}${ECHO_COLOR_GREEN}$MSG${ECHO_COLOR_NC}"		
		elif [[ "$COLOR" == "yellow" ]]; then
			echo -e "${G_SHPMLOG_INDENT}${ECHO_COLOR_YELLOW}$MSG${ECHO_COLOR_NC}"	
		else
			echo -e "${G_SHPMLOG_INDENT}$MSG"
		fi
	fi
}

shpm_log_operation() {
    shpm_log "================================================================"
	shpm_log "sh-pm: $1"
	shpm_log "================================================================"
}
