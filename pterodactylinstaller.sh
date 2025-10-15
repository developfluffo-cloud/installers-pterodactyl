#!/usr/bin/env bash
# ---------------------------------------
# Smart Installer for Pterodactyl + Nuble
# ---------------------------------------
set -euo pipefail
IFS=$'\n\t'

PANEL_DIR="/var/www/pterodactyl"
NUBLE_THEME_REPO="https://github.com/Nuble/panel-theme.git"

# ---------- FUNCTIONS ------------
install_panel() {
  echo "[*] Installing Pterodactyl Panel..."
  curl -sSL https://github.com/developfluffo-cloud/effective-goggles/raw/main/ptero_nuble_installer.sh -o /tmp/ptero_installer.sh
  chmod +x /tmp/ptero_installer.sh
  sudo /tmp/ptero_installer.sh install
}

install_nuble() {
  echo "[*] Installing Nuble Theme..."
  if [ ! -d "$PANEL_DIR" ]; then
    echo "[!] Pterodactyl Panel not found at $PANEL_DIR"
    echo "Please install the Panel first."
    return
  fi

  cd "$PANEL_DIR"
  if [ ! -d nuble-theme ]; then
    git clone "$NUBLE_THEME_REPO" nuble-theme
  fi
  cp -r nuble-theme/resources/views/* resources/views/
  cp -r nuble-theme/public/* public/
  yarn install && yarn build:production
  php artisan cache:clear && php artisan config:cache
  chown -R www-data:www-data resources public
  echo "[✔] Nuble Theme installed successfully!"
}

uninstall_all() {
  echo "[!] This will uninstall Panel + Nuble + DB + Wings"
  read -p "Type 'yes' to confirm: " CONFIRM
  if [[ "$CONFIRM" != "yes" ]]; then
    echo "Cancelled."
    return
  fi

  if [ -d "$PANEL_DIR" ]; then
    rm -rf "$PANEL_DIR"
    echo "[✔] Removed Pterodactyl files."
  fi

  systemctl stop wings pterodactyl-* || true
  systemctl disable wings pterodactyl-* || true
  rm -f /usr/local/bin/wings /etc/systemd/system/wings.service /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
  nginx -t || true
  systemctl reload nginx || true
  echo "[✔] Uninstallation complete."
}

# ---------- MENU ------------
while true; do
  clear
  echo "==============================="
  echo " Pterodactyl + Nuble Installer "
  echo "==============================="
  echo "1) Install Pterodactyl Panel"
  echo "2) Install Nuble Theme"
  echo "3) Uninstall Everything"
  echo "0) Exit"
  echo "==============================="
  read -p "Select an option: " OPT
  case "$OPT" in
    1) install_panel ;;
    2) install_nuble ;;
    3) uninstall_all ;;
    0) echo "Bye!"; exit 0 ;;
    *) echo "Invalid choice."; sleep 1 ;;
  esac
  echo
  read -p "Press Enter to continue..." _
done
