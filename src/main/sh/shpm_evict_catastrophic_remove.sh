
evict_catastrophic_remove() {
	# Evict catastrophic rm's when ROOT_DIR_PATH not set 
	if [[ -z "$ROOT_DIR_PATH" ]]; then
		echo "bootstrap.sh file not loaded!"
		return 1
	fi
}
