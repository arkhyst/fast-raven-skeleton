#!/bin/bash

# Initialize the skeleton. Run this script after cloning the repository.
# Usage: ./init.sh <domain>
# Example: ./init.sh mysite.local

if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

cp sites/main/config/env/env.php-example sites/main/config/env/env.php

composer install
npm install
./ops/deploy.sh $1 main

rm -- "$0"