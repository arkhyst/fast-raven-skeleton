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
    sass --watch "sites/$proj/src/web/assets/scss":"sites/$proj/public/assets/css" --style=compressed &
    chokidar "sites/$proj/src/web/assets/js/*.js" -c "javascript-obfuscator sites/$proj/src/web/assets/js --output sites/$proj/public/assets/js --compact true --self-defending true > /dev/null 2>&1" &
done

wait