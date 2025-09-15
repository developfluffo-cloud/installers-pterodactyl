#!/usr/bin/env bash
# ======================================================
# Full Pterodactyl VPS Installer by Developfluff
# Version: 1.0.0
# GitHub: https://github.com/developfluffo-cloud/installers-pterodactyl
# YouTube: https://youtube.com/@Developer
# License: MIT
# ======================================================

set -euo pipefail
IFS=$'\n\t'

APP_NAME="DevelopPanel Full Pterodactyl Installer"
VERSION="1.0.0"
BRANDING="Powered by Developfluff"
INSTALL_DIR="/var/www/pterodactyl"

info(){ printf "\n[INFO] %s\n" "$*"; }
warn(){ printf "\n[WARN] %s\n" "$*"; }
err(){ printf "\n[ERROR] %s\n" "$*" >&2; exit 1; }

banner(){
cat <<EOF

====================================================
  $APP_NAME   v$VERSION
  $BRANDING
  Author: Developfluff
  YouTube: https://youtube.com/@Developer
====================================================

EOF
}

# ----------------------------
# Update & dependencies
# ----------------------------
update_system(){
    info "Updating system..."
    sudo apt update && sudo apt upgrade -y
    info "Installing dependencies..."
    sudo apt install -y software-properties-common curl wget unzip git tar
    sudo apt install -y php-cli php-mbstring php-bcmath php-fpm php-gd php-curl php-mysql php-xml composer mariadb-server mariadb-client nginx
}

# ----------------------------
# Docker installation
# ----------------------------
install_docker(){
    info "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo bash
    info "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# ----------------------------
# Pterodactyl Panel installation
# ----------------------------
install_panel(){
    info "Installing Pterodactyl Panel in $INSTALL_DIR..."
    sudo mkdir -p "$INSTALL_DIR"
    sudo chown -R "$USER":"$USER" "$INSTALL_DIR"
    git clone https://github.com/pterodactyl/panel.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    git checkout release
    composer install --no-dev --optimize-autoloader
    cp .env.example .env
    php artisan key:generate
}

# ----------------------------
# Database setup
# ----------------------------
setup_database(){
    info "Setting up MariaDB..."
    sudo mysql -e "CREATE DATABASE pterodactyl;"
    sudo mysql -e "CREATE USER 'ptero'@'127.0.0.1' IDENTIFIED BY 'password';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON pterodactyl.* TO 'ptero'@'127.0.0.1';"
    sudo mysql -e "FLUSH PRIVILEGES;"
}

# ----------------------------
# Nginx configuration
# ----------------------------
setup_nginx(){
    info "Setting up Nginx..."
    sudo tee /etc/nginx/sites-available/pterodactyl > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    root $INSTALL_DIR/public;

    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

    sudo ln -s /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/pterodactyl
    sudo nginx -t
    sudo systemctl restart nginx
}

# ----------------------------
# Optional branding
# ----------------------------
add_branding(){
    echo "This is DevelopPanel. Installed using the official Developfluff installer." > "$INSTALL_DIR/README.txt"
    echo "🔥 DEVELOPFLUFF ORIGINAL INSTALLER 🔥" > "$INSTALL_DIR/logo.txt"
    sudo chmod 644 "$INSTALL_DIR/README.txt" "$INSTALL_DIR/logo.txt"
}

# ----------------------------
# Run all
# ----------------------------
banner
update_system
install_docker
install_panel
setup_database
setup_nginx
add_branding

cat <<EOF

======== INSTALL COMPLETE ========

$APP_NAME installed in: $INSTALL_DIR
$BRANDING
Author: Developfluff (Developer)
YouTube: https://youtube.com/@Developer

You can now complete Pterodactyl setup via web browser.
===================================

EOF
