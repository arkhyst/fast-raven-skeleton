#!/bin/bash

#==============================================================================
# FastRaven Framework - Watch Script
#==============================================================================
# This script automates the compile process of .js and .scss files inside
# the src/resources directory of each project.
#
# Usage: ./watch.sh
#==============================================================================

set -e  # Exit on error

projects=("main")

cd "$(dirname "${BASH_SOURCE[0]}")"/..

for proj in "${projects[@]}"; do
    sass --watch "sites/$proj/src/resources":"sites/$proj/public/resources" --style=compressed &
    chokidar "sites/$proj/src/resources/*.js" -c "javascript-obfuscator sites/$proj/src/resources --output sites/$proj/public/resources --compact true --self-defending true > /dev/null 2>&1" &
done

wait