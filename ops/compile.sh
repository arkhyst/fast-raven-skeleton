#!/bin/bash

# Web assets compile script
# Autodetects sites and compiles .js and .scss files.

# Usage: ./compile.sh [--watch|-w]

set -e

WATCH=false
if [[ "$1" == "--watch" || "$1" == "-w" ]]; then
    WATCH=true
fi

cd "$(dirname "${BASH_SOURCE[0]}")"/..

SITES=()
for d in sites/*/; do
    if [ -d "$d" ]; then
        SITES+=("$(basename "$d")")
    fi
done

if [ ${#SITES[@]} -eq 0 ]; then
    echo "No sites found in sites/"
    exit 0
fi

# ----------------------------------------------------------------------------

pids=()

for proj in "${SITES[@]}"; do
    echo "Compiling assets for: $proj"
    
    SCSS_SRC="sites/$proj/src/web/assets/scss"
    CSS_DEST="sites/$proj/public/assets/css"
    JS_SRC="sites/$proj/src/web/assets/js"
    JS_DEST="sites/$proj/public/assets/js"

    mkdir -p "$CSS_DEST"
    mkdir -p "$JS_DEST"

    if [ -d "$SCSS_SRC" ]; then
        if ls "$SCSS_SRC"/*.scss 1> /dev/null 2>&1; then
            sass "$SCSS_SRC":"$CSS_DEST" --style=compressed --update
        fi
    fi

    if [ -d "$JS_SRC" ]; then
        javascript-obfuscator "$JS_SRC" --output "$JS_DEST" --compact true --self-defending true > /dev/null 2>&1 || true
    fi

    echo "Compilation complete."

    if [ "$WATCH" = true ]; then
        sass --watch "$SCSS_SRC":"$CSS_DEST" --style=compressed &
        pids+=($!)
        
        chokidar "$JS_SRC/*.js" -c "javascript-obfuscator $JS_SRC --output $JS_DEST --compact true --self-defending true > /dev/null 2>&1" &
        pids+=($!)
    fi
done

if [ "$WATCH" = true ]; then
    wait "${pids[@]}"
fi