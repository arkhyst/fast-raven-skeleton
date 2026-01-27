#!/bin/bash

#==============================================================================
# FastRaven Framework - Build Script
#==============================================================================
# This script automates the build process of a FastRaven site.
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
    echo -e "${GREEN}     FastRaven Site Scaffolding${NC}"
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
    mkdir -p "$SITE_PATH/src/cdn"
    mkdir -p "$SITE_PATH/src/views"
    mkdir -p "$SITE_PATH/src/web/templates/pages"
    mkdir -p "$SITE_PATH/src/web/templates/fragments"
    mkdir -p "$SITE_PATH/src/web/templates/mails"
    mkdir -p "$SITE_PATH/src/web/assets/scss"
    mkdir -p "$SITE_PATH/src/web/assets/js"
    mkdir -p "$SITE_PATH/src/web/assets/fonts"
    mkdir -p "$SITE_PATH/src/web/assets/img"
    mkdir -p "$SITE_PATH/public/assets/css"
    mkdir -p "$SITE_PATH/public/assets/js"
    mkdir -p "$SITE_PATH/public/assets/fonts"
    mkdir -p "$SITE_PATH/public/assets/img"
    mkdir -p "$SITE_PATH/storage/cache"
    mkdir -p "$SITE_PATH/storage/logs"
    mkdir -p "$SITE_PATH/storage/uploads"
    
    #==========================================================================
    # CREATE .gitkeep FILES
    #==========================================================================
        
    touch "$SITE_PATH/src/web/assets/fonts/.gitkeep"
    touch "$SITE_PATH/src/web/assets/img/.gitkeep"
    touch "$SITE_PATH/public/assets/fonts/.gitkeep"
    touch "$SITE_PATH/public/assets/img/.gitkeep"
    touch "$SITE_PATH/storage/cache/.gitkeep"
    touch "$SITE_PATH/storage/logs/.gitkeep"
    touch "$SITE_PATH/storage/uploads/.gitkeep"
    
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
require __DIR__ . "/../../vendor/autoload.php";

use FastRaven\Server;

// Server initialization. sitePath SHOULD ALWAYS BE __DIR__ unless you know what you are doing.
$server = Server::initialize(__DIR__);

// Server configuration.
$server->configure(
    Server::getConfiguration(),
    Server::getTemplate(),
    Server::getMiddleware(),
    Server::getViewRouter(),
    Server::getApiRouter(),
    Server::getCdnRouter()
);

// This is where the magic happens.
$server->run();
EOF
    
    #==========================================================================
    # CREATE CONFIGURATION FILES
    #==========================================================================
    
    # config.php
    cat > "$SITE_PATH/config/config.php" <<'EOF'
<?php

use FastRaven\Components\Core\Config;

// Main Configuration. siteName is not the subdomain.
$config = Config::new("${SITE_NAME}", false);

// Cookie Session Configuration.
$config->configureAuthorization("YOURSESSIONNAME", 7, false);

// Redirect settings: notFound path, unauthorized path, subdomain (empty = main domain)
$config->configureRedirects("/", "/", "");

// Define whether to register logs or restrict what data to register.
$config->configurePrivacy(true, true);

// Configure rate-limiting per middleware type (VIEW, API, CDN). -1 = disabled.
$config->configureRateLimits(200, 200, 200);

// Configure input/file size limits in KB. -1 = disabled.
$config->configureLengthLimits(256, 5120);

// File-based cache settings. Set gcProbability to 0 to disable framework GC.
$config->configureCache(1, 50);

return $config;
EOF
    
    # Replace ${SITE_NAME} with actual site name
    sed -i "s/\${SITE_NAME}/$SITE_NAME/g" "$SITE_PATH/config/config.php" 2>/dev/null || \
    perl -pi -e "s/\\\${SITE_NAME}/$SITE_NAME/g" "$SITE_PATH/config/config.php"
    
    # template.php
    cat > "$SITE_PATH/config/template.php" <<'EOF'
<?php

use FastRaven\Components\Core\Template;

use FastRaven\Workers\Bee;

// Default template for all views.
$template = Template::new("main.php", "Fast Raven Site", Bee::env("VERSION", "0.0.1"));
$template->setFavicon("favicon.png")
         ->setBeforeFragments(["header.php"])
         ->addStyle("style.css")
         ->addScript("main.js");

return $template;
EOF

    # middleware.php
    cat > "$SITE_PATH/config/middleware.php" <<'EOF'
<?php

use FastRaven\Workers\LogWorker;

use FastRaven\Components\Http\Request;
use FastRaven\Components\Routing\Middleware;

// Create a new middleware holder instance.
$middleware = Middleware::new();

// Add a new available to use middleware.
$middleware->add("alwaysPass", function(Request $request): bool {
    LogWorker::log("This gets executed BEFORE endpoint execution -- Check config/middleware.php to remove this line.");
    // You can limit it to request types. 
    // if($request->getType() === EndpointType::API)
    // Or use Shared methods for more complex operations.
    // Shared\HelperClass::log("test");

    return true; // Return false to deny request processing
});

return $middleware;
EOF
    
    # router/views.php
    cat > "$SITE_PATH/config/router/views.php" <<'EOF'
<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

use FastRaven\Types\EndpointType;

// View Router configuration. Remember to return a template from each view.
$viewRouter = Router::new(EndpointType::VIEW)
    ->add(Endpoint::view(false, "/", "Home.php"))
    ->add(Endpoint::view(false, "/ping", "Ping.php", "alwaysPass"));

return $viewRouter;
EOF
    
    # router/api.php
    cat > "$SITE_PATH/config/router/api.php" <<'EOF'
<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

use FastRaven\Types\EndpointType;

// API Router configuration. /api/ prefix is automatically added.
$apiRouter = Router::new(EndpointType::API)
    ->add(Endpoint::api(false, "GET", "/health", "Health.php"))
    ->add(Endpoint::api(false, "GET", "/pong", "Pong.php"));

return $apiRouter;
EOF
    
    # router/cdn.php
    cat > "$SITE_PATH/config/router/cdn.php" <<'EOF'
<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

use FastRaven\Types\EndpointType;

// CDN Router configuration. /cdn/ prefix is automatically added.
$cdnRouter = Router::new(EndpointType::CDN)
    ->add(Endpoint::cdn(false, "GET", "/favicon", "Favicon.php"));

return $cdnRouter;
EOF
    
    #==========================================================================
    # CREATE ENVIRONMENT FILES
    #==========================================================================
    
    # .env-example
    cat > "$SITE_PATH/config/env/.env-example" <<'EOF'
STATE=dev
VERSION=0.0.1
EOF
    
    # .env.dev-example
    cat > "$SITE_PATH/config/env/.env.dev-example" <<'EOF'
SITE_ADDRESS=fastraven.loc
AUTH_DOMAIN=.fastraven.loc

DB_HOST=localhost

DB_NAME=test
DB_USER=raven
DB_PASS=secret

DB_SSL=false
DB_SSL_CA=/path/to/ca.pem
DB_PERSISTENT=true

SMTP_HOST=smtp.fastraven.loc
SMTP_ENCRYPTION=tls
SMTP_PORT=587
SMTP_USER=raven@fastraven.loc
SMTP_PASS=secret
EOF
    
    # .env.prod-example
    cat > "$SITE_PATH/config/env/.env.prod-example" <<'EOF'
SITE_ADDRESS=fastraven.loc
AUTH_DOMAIN=.fastraven.loc

DB_HOST=localhost

DB_NAME=test
DB_USER=raven
DB_PASS=secret

DB_SSL=false
DB_SSL_CA=/path/to/ca.pem
DB_PERSISTENT=true

SMTP_HOST=smtp.fastraven.loc
SMTP_ENCRYPTION=tls
SMTP_PORT=587
SMTP_USER=raven@fastraven.loc
SMTP_PASS=secret
EOF
    
    # Create actual .env file
    cat > "$SITE_PATH/config/env/.env" <<'EOF'
STATE=dev
VERSION=0.0.1
EOF
    
    # Create actual .env.dev file
    cat > "$SITE_PATH/config/env/.env.dev" <<'EOF'
SITE_ADDRESS=fastraven.loc
AUTH_DOMAIN=.fastraven.loc

DB_HOST=localhost

DB_NAME=test
DB_USER=raven
DB_PASS=secret

DB_SSL=false
DB_SSL_CA=/path/to/ca.pem
DB_PERSISTENT=true

SMTP_HOST=smtp.fastraven.loc
SMTP_ENCRYPTION=tls
SMTP_PORT=587
SMTP_USER=raven@fastraven.loc
SMTP_PASS=secret
EOF
    
    # Create actual .env.prod file
    cat > "$SITE_PATH/config/env/.env.prod" <<'EOF'
SITE_ADDRESS=fastraven.loc
AUTH_DOMAIN=.fastraven.loc

DB_HOST=localhost

DB_NAME=test
DB_USER=raven
DB_PASS=secret

DB_SSL=false
DB_SSL_CA=/path/to/ca.pem
DB_PERSISTENT=true

SMTP_HOST=smtp.fastraven.loc
SMTP_ENCRYPTION=tls
SMTP_PORT=587
SMTP_USER=raven@fastraven.loc
SMTP_PASS=secret
EOF
    
    #==========================================================================
    # CREATE VIEW HANDLERS
    #==========================================================================
    
    # Home.php - View handler for /
    cat > "$SITE_PATH/src/views/Home.php" <<'EOF'
<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Http\Request;

return function(Request $request, Template $baseTemplate): Template {
    $page = Template::new("main.php", $baseTemplate->getTitle());
    return $page;
};
EOF
    
    # Ping.php - View handler for /ping
    cat > "$SITE_PATH/src/views/Ping.php" <<'EOF'
<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Http\Request;
use FastRaven\Components\Data\Item;

return function(Request $request, Template $baseTemplate): Template {
    $page = Template::new("ping.php", $baseTemplate->getTitle()." - Ping test");
    $page->addData("test", "This is a test");
    return $page;
};
EOF
    
    #==========================================================================
    # CREATE DEFAULT TEMPLATE PAGES
    #==========================================================================
    
    cat > "$SITE_PATH/src/web/templates/pages/main.php" <<'EOF'
<h1>Fast Raven is working hard to launch this site...</h1>
EOF
    
    # ping.php
    cat > "$SITE_PATH/src/web/templates/pages/ping.php" <<'EOF'
<h4>PING -> <span data-lang="FR_PING_EXAMPLE"></span></h4>
<p><?= $template->getData("test"); ?></p>
EOF
    
    #==========================================================================
    # CREATE DEFAULT FRAGMENTS
    #==========================================================================
    
    # header.php
    cat > "$SITE_PATH/src/web/templates/fragments/header.php" <<'EOF'
<div style="display: flex; justify-content: space-between;">
    <h3>This is a test fragment / </h3>
    <h3>This can be added to templates so it gets reused</h3>
</div>
EOF
    
    #==========================================================================
    # CREATE DEFAULT MAIL TEMPLATE
    #==========================================================================
    
    # welcome.php
    cat > "$SITE_PATH/src/web/templates/mails/welcome.php" <<'EOF'
<h1>This is a test email</h1>
<p>Thank you for using Fast Raven!</p>
EOF
    
    #==========================================================================
    # CREATE DEFAULT API ENDPOINT
    #==========================================================================
    
    cat > "$SITE_PATH/src/api/Health.php" <<'EOF'
<?php
use FastRaven\Components\Http\Response;

return function($request) {
    return Response::new(true, 200, "Hello there!", [
        "ping" => "pong",
        "timestamp" => time()
    ]);
};
EOF
    
    # Pong.php
    cat > "$SITE_PATH/src/api/Pong.php" <<'EOF'
<?php

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;

return function(Request $request): Response {
    return Response::new(true, 200, "This should give a little information.", "PONG");
};
EOF
    
    #==========================================================================
    # CREATE DEFAULT CDN ENDPOINT
    #==========================================================================
    
    cat > "$SITE_PATH/src/cdn/Favicon.php" <<'EOF'
<?php

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;

return function(Request $request): Response {
    return Response::file(true, "fast-raven.png");
};
EOF
    
    #==========================================================================
    # CREATE DEFAULT ASSETS
    #==========================================================================
    
    # style.scss (empty)
    touch "$SITE_PATH/src/web/assets/scss/style.scss"
    
    # main.js
    cat > "$SITE_PATH/src/web/assets/js/main.js" <<'EOF'
$(document).ready(function() {
    
});
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
    echo -e "  3. Add view handlers in ${SITE_NAME}/src/views/"
    echo -e "  4. Add templates in ${SITE_NAME}/src/web/templates/"
    echo -e "  5. Add API endpoints in ${SITE_NAME}/src/api/"
    echo ""
    
    exit 0
fi

#==============================================================================
# NORMAL BUILD PROCESS
#==============================================================================

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}FastRaven Build${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

composer install
npm install

echo ""
echo -e "${GREEN}Build complete!${NC}"
echo ""