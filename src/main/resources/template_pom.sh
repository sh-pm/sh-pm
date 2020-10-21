GROUP_ID=bash
ARTIFACT_ID=
VERSION=v0.1.0

declare -A REPOSITORY=( \
	[host]="shpmcenter.com" \
	[port]=49156 \
);

declare -A DEPENDENCIES=( \
    [sh-pm]=v3.0.5
    [sh-logger]=v1.3.0 \
    [sh-unit]=v1.5.0 \
);