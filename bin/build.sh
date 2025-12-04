#!/bin/bash

#==============================================================================
# SmartGoblin Framework - Build Script
#==============================================================================
# This script automates the build process of a SmartGoblin site.
# It can also scaffold new sites with the proper directory structure.
#
# Usage: 
#   ./build.sh              - Install dependencies for existing sites
#   ./build.sh <site-name>  - Create new site and deploy it
#
# Example: ./build.sh myapp
#==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#==============================================================================
# FUNCTIONS
#==============================================================================

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

#==============================================================================
# DIRECTORY SETUP
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

#==============================================================================
# CHECK FOR SITE SCAFFOLDING
#==============================================================================

if [ -n "$1" ]; then
    SITE_NAME="$1"
    SITE_PATH="$PROJECT_ROOT/sites/$SITE_NAME"
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}     SmartGoblin Site Scaffolding${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    # Check if site already exists
    if [ -d "$SITE_PATH" ]; then
        print_error "Site folder already exists: $SITE_PATH"
        exit 1
    fi
    
    print_step "Creating new site: $SITE_NAME"
    
    #==========================================================================
    # CREATE DIRECTORY STRUCTURE
    #==========================================================================
    
    # Create main directories
    mkdir -p "$SITE_PATH"
    mkdir -p "$SITE_PATH/config/env"
    mkdir -p "$SITE_PATH/config/router"
    mkdir -p "$SITE_PATH/src/api"
    mkdir -p "$SITE_PATH/src/views"
    mkdir -p "$SITE_PATH/src/resources"
    mkdir -p "$SITE_PATH/public/assets"
    mkdir -p "$SITE_PATH/public/resources"
    
    #==========================================================================
    # CREATE .gitkeep FILES
    #==========================================================================
        
    touch "$SITE_PATH/config/router/.gitkeep"
    touch "$SITE_PATH/src/api/.gitkeep"
    touch "$SITE_PATH/src/resources/.gitkeep"
    touch "$SITE_PATH/src/views/.gitkeep"
    touch "$SITE_PATH/public/assets/.gitkeep"
    touch "$SITE_PATH/public/resources/.gitkeep"
    
    #==========================================================================
    # CREATE .gitignore
    #==========================================================================
    
    cat > "$SITE_PATH/.gitignore" <<'EOF'
/logs
.env
.env.dev
.env.prod
EOF
    
    #==========================================================================
    # CREATE .htaccess
    #==========================================================================
    
    cat > "$SITE_PATH/.htaccess" <<'EOF'
RewriteEngine On
RewriteBase /

Options -Indexes -MultiViews

RewriteRule ^public/ - [L]
RewriteRule ^(favicon\.ico|robots\.txt|sitemap\.xml)$ public/$1 [L]

RewriteRule \.php$ index.php [QSA,L]
RewriteRule ^ index.php [QSA,L]

<Files "index.php">
  Require all granted
</Files>
EOF
    
    #==========================================================================
    # CREATE index.php
    #==========================================================================
    
    cat > "$SITE_PATH/index.php" <<'EOF'
<?php

declare(strict_types=1);
require __DIR__ . "/../vendor/autoload.php";

use SmartGoblin\Server;

// sitePath SHOULD ALWAYS BE __DIR__ unless you know what you are doing. Leave empty for the same value as preload.

// Environment preload.
Server::preload(__DIR__);


// Retrieve configuration, template and routers.
$config = Server::getConfiguration();
$template = Server::getTemplate();
$viewRouter = Server::getViewRouter();
$apiRouter = Server::getApiRouter();

// Server initialization.
$server = Server::createInstance();

// Server configuration.
$server->configure($config, $template, $viewRouter, $apiRouter);

// This is where the magic happens.
$server->run();

?>
EOF
    
    #==========================================================================
    # CREATE CONFIGURATION FILES
    #==========================================================================
    
    # config.php
    cat > "$SITE_PATH/config/config.php" <<'EOF'
<?php
use SmartGoblin\Components\Core\Config;
use SmartGoblin\Workers\Bee;

// Main Configuration
$config = Config::new("${SITE_NAME}", false);

// Cookie Session Configuration
$config->configureAuthorization("YOURSESSIONNAME", 7, Bee::env("SITE_ADDRESS", "localhost"));

// Redirect Configuration
$config->configureNotFoundRedirects("/");
$config->configureUnauthorizedRedirects("/login", "");

return $config;
EOF
    
    # Replace ${SITE_NAME} with actual site name
    sed -i "s/\${SITE_NAME}/$SITE_NAME/g" "$SITE_PATH/config/config.php" 2>/dev/null || \
    perl -pi -e "s/\\\${SITE_NAME}/$SITE_NAME/g" "$SITE_PATH/config/config.php"
    
    # template.php
    cat > "$SITE_PATH/config/template.php" <<'EOF'
<?php
use SmartGoblin\Components\Core\Template;

$template = Template::new("SmartGoblin Site", "1.0.0", "en");

// Add your styles and scripts here
// $template->addStyle("resources/main.css");
// $template->addScript("resources/main.js");

return $template;
EOF
    
    # router/views.php
    cat > "$SITE_PATH/config/router/views.php" <<'EOF'
<?php
use SmartGoblin\Components\Routing\Router;
use SmartGoblin\Components\Routing\Endpoint;

return Router::endpoints([
    Endpoint::view(false, "/", "main.html"),
]);
EOF
    
    # router/api.php
    cat > "$SITE_PATH/config/router/api.php" <<'EOF'
<?php
use SmartGoblin\Components\Routing\Router;
use SmartGoblin\Components\Routing\Endpoint;

return Router::endpoints([
    Endpoint::api(false, "GET", "/health", "Health.php"),
]);
EOF
    
    #==========================================================================
    # CREATE ENVIRONMENT FILES
    #==========================================================================
    
    # .env-example
    cat > "$SITE_PATH/config/env/.env-example" <<'EOF'
STATE=dev
SITE_ADDRESS=localhost
EOF
    
    # .env.dev-example
    cat > "$SITE_PATH/config/env/.env.dev-example" <<'EOF'
# Development Environment
DB_HOST=localhost
DB_NAME=smartgoblin_dev
DB_USER=root
DB_PASS=
DEBUG=true
EOF
    
    # .env.prod-example
    cat > "$SITE_PATH/config/env/.env.prod-example" <<'EOF'
# Production Environment
DB_HOST=localhost
DB_NAME=smartgoblin_prod
DB_USER=prod_user
DB_PASS=secure_password
DEBUG=false
EOF
    
    # Create actual .env file
    cat > "$SITE_PATH/config/env/.env" <<'EOF'
STATE=dev
SITE_ADDRESS=localhost
EOF
    
    # Create actual .env.dev file
    cat > "$SITE_PATH/config/env/.env.dev" <<'EOF'
# Development Environment
DB_HOST=localhost
DB_NAME=smartgoblin_dev
DB_USER=root
DB_PASS=
DEBUG=true
EOF
    
    #==========================================================================
    # CREATE DEFAULT VIEW
    #==========================================================================
    
    cat > "$SITE_PATH/src/views/main.html" <<'EOF'
    <h1>Welcome to SmartGoblin!</h1>
    <p>Your new site is ready to go.</p>
    <p>Edit this file at <code>src/views/main.html</code></p>
EOF
    
    #==========================================================================
    # CREATE DEFAULT API ENDPOINT
    #==========================================================================
    
    cat > "$SITE_PATH/src/api/Health.php" <<'EOF'
<?php
use SmartGoblin\Components\Http\Response;

return function($request) {
    return Response::new(true, 200, "Hello there!", [
        "ping" => "pong",
        "timestamp" => time()
    ]);
};
EOF
    
    #==========================================================================
    # DEPLOY SITE
    #==========================================================================
    
    echo ""
    print_step "Deploying site to Apache2..."
    echo ""
    
    # Run deploy script
    if [ -f "$SCRIPT_DIR/deploy.sh" ]; then
        sudo bash "$SCRIPT_DIR/deploy.sh" "${SITE_NAME}.local" "$SITE_NAME"
    else
        print_warning "deploy.sh not found, skipping deployment"
    fi
    
    #==========================================================================
    # FINAL MESSAGE
    #==========================================================================
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Site Created Successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "Site location: ${BLUE}$SITE_PATH${NC}"
    echo -e "Site URL: ${BLUE}https://${SITE_NAME}.local${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Add '${SITE_NAME}.local' to /etc/hosts"
    echo -e "  2. Edit configuration in ${SITE_NAME}/config/"
    echo -e "  3. Add your views in ${SITE_NAME}/src/views/"
    echo -e "  4. Add your API endpoints in ${SITE_NAME}/src/api/"
    echo ""
    
    exit 0
fi

#==============================================================================
# NORMAL BUILD PROCESS
#==============================================================================

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SmartGoblin Build${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

composer install
npm install

echo ""
echo -e "${GREEN}Build complete!${NC}"
echo ""