#!/bin/bash

##
# Main entry for monorepository build.
# Triggers circleci builds for all modified projects in order respecting their dependencies.
# 
# Usage:
#   build.sh
##

set -e

# Find script directory (no support for symlinks)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Configuration with default values
: "${CI:=$DIR/circleci.sh}"

echo "${CI} hash last"
ls -all
echo $CIRCLE_SHA1

# Resolve commit range for current build 
LAST_SUCCESSFUL_COMMIT=$(${CI} hash last)
if [[ ${LAST_SUCCESSFUL_COMMIT} == "null" ]]; then
    COMMIT_RANGE="origin/master"
else
    COMMIT_RANGE="$(${CI} hash current)..${LAST_SUCCESSFUL_COMMIT}"
fi
echo "Commit range: $COMMIT_RANGE"

# Collect all modified projects
PROJECTS_TO_BUILD=$($DIR/list-projects-to-build.sh $COMMIT_RANGE)
echo "Following projects need to be built"
echo -e "$PROJECTS_TO_BUILD"

# Build all modified projects
echo -e "$PROJECTS_TO_BUILD" | while read PROJECTS; do
    $DIR/build-projects.sh ${PROJECTS}
done;