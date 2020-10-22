GROUP_ID=bash
ARTIFACT_ID=
VERSION=v0.1.0

declare -A REPOSITORY=( \
	[host]="shpmcenter.com" \
	[port]=49156 \
);

declare -A DEPENDENCIES=( \
    [sh-pm]=v3.2.3
    [sh-logger]=v1.4.0 \
    [sh-unit]=v1.5.4 \
);