#!/bin/bash

# --------------------------
# Pterodactyl Wings Fix & Cloudflare Tunnel Setup
# --------------------------

# 1️⃣ Update config.yml
cat > /etc/pterodactyl/config.yml <<'EOF'
debug: false
app_name: Pterodactyl
uuid: 961bbd6c-fd20-4961-8b97-71d7d7033105
token_id: FE7m1i2l45h8x0Tj
token: lqPglqAYkgPlQQ6VreJinNoSEQEvGdO6fgjjozuHsFaaaZHlvx2qjYw95f

api:
  host: 0.0.0.0
  port: 8443
  ssl:
    enabled: false
  disable_remote_download: false
  upload_limit: 100
  trusted_proxies: []

system:
  root_directory: /var/lib/pterodactyl
  log_directory: /var/log/pterodactyl
  data: /var/lib/pterodactyl/volumes
  archive_directory: /var/lib/pterodactyl/archives

sftp:
  host: 0.0.0.0
  port: 2022
EOF

echo "[✔] config.yml updated."

# 2️⃣ Ensure directories exist
sudo mkdir -p /var/lib/pterodactyl /var/log/pterodactyl
sudo chown -R root:root /var/lib/pterodactyl /var/log/pterodactyl
echo "[✔] Required directories created."

# 3️⃣ Restart Wings
sudo systemctl daemon-reload
sudo systemctl restart wings

# Wait a few seconds and check status
sleep 3
sudo systemctl status wings --no-pager

# 4️⃣ Install cloudflared (if not installed)
if ! command -v cloudflared &> /dev/null; then
    echo "[ℹ] Installing cloudflared..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -O /tmp/cloudflared.deb
    sudo dpkg -i /tmp/cloudflared.deb
fi

# 5️⃣ Run Cloudflare Tunnel for Wings HTTP
echo "[ℹ] Starting Cloudflare Tunnel..."
nohup cloudflared tunnel --url http://localhost:8443 --no-autoupdate --name wings-tunnel > /var/log/cloudflared-wings.log 2>&1 &

echo "[✔] Cloudflare Tunnel started for wings.youdad.qzz.io -> localhost:8443"
echo "Check tunnel logs: tail -f /var/log/cloudflared-wings.log"
