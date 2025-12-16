#!/bin/bash

#==============================================================================
# FastRaven Framework - Apache2 Deployment Script
#==============================================================================
# This script automates the deployment of a FastRaven site to Apache2 with
# SSL certificate generation using mkcert.
#
# Usage: ./deploy.sh <domain> <site-folder>
# Example: ./deploy.sh mysite.local main
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
# ARGUMENT VALIDATION
#==============================================================================

if [ -z "$1" ]; then
    print_error "Domain argument is required"
    echo "Usage: $0 <domain> <site-folder>"
    echo "Example: $0 mysite.local main"
    exit 1
fi

if [ -z "$2" ]; then
    print_error "Site folder argument is required"
    echo "Usage: $0 <domain> <site-folder>"
    echo "Example: $0 mysite.local main"
    exit 1
fi

DOMAIN="$1"
SITE_FOLDER="sites/$2"

#==============================================================================
# DIRECTORY SETUP
#==============================================================================

# Get the parent directory (project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"

# Validate site folder exists
SITE_PATH="$PROJECT_ROOT/$SITE_FOLDER"

if [ ! -d "$SITE_PATH" ]; then
    print_error "Site folder does not exist: $SITE_PATH"
    echo "Available folders in project root:"
    ls -d "$PROJECT_ROOT"/*/ 2>/dev/null | xargs -n 1 basename || echo "  (none)"
    exit 1
fi

print_step "Project name: $PROJECT_NAME"

#==============================================================================
# CREATE SYMBOLIC LINK
#==============================================================================

print_step "Creating symbolic link in /var/www..."

WWW_LINK="/var/www/$PROJECT_NAME"

if [ -L "$WWW_LINK" ]; then
    sudo rm "$WWW_LINK"
fi

sudo ln -s "$PROJECT_ROOT" "$WWW_LINK"
print_success "Symbolic link created: $WWW_LINK -> $PROJECT_ROOT"

#==============================================================================
# CREATE CERTIFICATE DIRECTORY
#==============================================================================

print_step "Creating certificate directory..."

CERT_DIR="$PROJECT_ROOT/_cert"

if [ ! -d "$CERT_DIR" ]; then
    mkdir -p "$CERT_DIR"
    print_success "Certificate directory created: $CERT_DIR"
else
    print_warning "Certificate directory already exists: $CERT_DIR"
fi

#==============================================================================
# INSTALL MKCERT IF NEEDED
#==============================================================================

print_step "Checking for mkcert..."

if ! command -v mkcert &> /dev/null; then
    print_warning "mkcert not found, installing..."
    
    # Detect OS and install mkcert
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        if command -v apt-get &> /dev/null; then
            # Debian/Ubuntu
            sudo apt-get update
            sudo apt-get install -y libnss3-tools
            
            # Download and install mkcert
            MKCERT_VERSION="v1.4.4"
            wget -O mkcert "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64"
            chmod +x mkcert
            sudo mv mkcert /usr/local/bin/
        elif command -v yum &> /dev/null; then
            # RHEL/CentOS/Fedora
            sudo yum install -y nss-tools
            
            MKCERT_VERSION="v1.4.4"
            wget -O mkcert "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64"
            chmod +x mkcert
            sudo mv mkcert /usr/local/bin/
        else
            print_error "Unsupported package manager. Please install mkcert manually."
            exit 1
        fi
    else
        print_error "Unsupported OS. Please install mkcert manually."
        exit 1
    fi
    
    print_success "mkcert installed successfully"
else
    print_success "mkcert is already installed"
fi

#==============================================================================
# GENERATE SSL CERTIFICATE
#==============================================================================

print_step "Generating SSL certificate for $DOMAIN..."

mkcert -install

cd "$CERT_DIR"
mkcert "$DOMAIN"

# Rename certificates to standard names
mv "${DOMAIN}.pem" "${DOMAIN}.crt"
mv "${DOMAIN}-key.pem" "${DOMAIN}.key"

print_success "SSL certificate generated"

#==============================================================================
# CREATE APACHE2 SITE CONFIGURATION
#==============================================================================

print_step "Creating Apache2 site configuration..."

SITE_CONFIG="/etc/apache2/sites-available/${DOMAIN}.conf"

sudo tee "$SITE_CONFIG" > /dev/null <<EOF
<VirtualHost *:443>
    ServerName ${DOMAIN}
    
    DocumentRoot ${WWW_LINK}/${SITE_FOLDER}
    
    <Directory ${WWW_LINK}/${SITE_FOLDER}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile ${CERT_DIR}/${DOMAIN}.crt
    SSLCertificateKeyFile ${CERT_DIR}/${DOMAIN}.key
    
    # Security Headers
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    
    # Logging
    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}-error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}-access.log combined
</VirtualHost>

# Redirect HTTP to HTTPS
<VirtualHost *:80>
    ServerName ${DOMAIN}
    
    Redirect permanent / https://${DOMAIN}/
</VirtualHost>
EOF

print_success "Apache2 site configuration created: $SITE_CONFIG"

#==============================================================================
# ENABLE SITE
#==============================================================================

print_step "Enabling site in Apache2..."

sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2enmod headers

sudo a2ensite "${DOMAIN}.conf"
sudo systemctl restart apache2

print_success "Site enabled: ${DOMAIN}.conf"

#==============================================================================
# FINAL INSTRUCTIONS
#==============================================================================

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Your site is now available at:"
echo -e "  ${BLUE}https://${DOMAIN}${NC}"
echo -e "  ${BLUE}https://www.${DOMAIN}${NC}"
echo ""
echo -e "Configuration files:"
echo -e "  Site folder: ${SITE_FOLDER}"
echo -e "  Apache config: ${SITE_CONFIG}"
echo ""
echo -e "${YELLOW}Note:${NC} Make sure to add '${DOMAIN}' to your /etc/hosts file:"
echo -e "  ${BLUE}sudo echo '127.0.0.1 ${DOMAIN}' >> /etc/hosts${NC}"
echo ""
