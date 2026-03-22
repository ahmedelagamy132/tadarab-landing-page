#!/bin/bash

SERVER="49.13.63.29"
USER="root"
REMOTE_DIR="/var/www/html"

echo "=== Deploying landing page to server ==="
echo

# Create zip archive of the landing page
echo "Creating archive..."
tar -czf landing-page.tar.gz index.html assets/
echo "✓ Archive created: landing-page.tar.gz"
echo

# Copy files to server
echo "Copying files to server..."
scp -i ~/.ssh/id_rsa_deploy landing-page.tar.gz ${USER}@${SERVER}:/tmp/
echo "✓ Files copied"
echo

# Commands to run on server
echo "Installing files on server..."
ssh -i ~/.ssh/id_rsa_deploy ${USER}@${SERVER} << 'ENDSSH'
# Update package list and install nginx if not present
apt-get update
apt-get install -y nginx

# Backup existing site
if [ -d /var/www/html ]; then
  cp -r /var/www/html /var/www/html.backup.$(date +%Y%m%d_%H%M%S)
fi

# Create directory
mkdir -p /var/www/html

# Extract files
tar -xzf /tmp/landing-page.tar.gz -C /var/www/html/
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Configure nginx
cat > /etc/nginx/sites-available/default << 'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|webp|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
NGINX

# Test and restart nginx
nginx -t && systemctl restart nginx

# Enable nginx to start on boot
systemctl enable nginx

echo "✓ Installation complete"
ENDSSH

echo
echo "=== Cleaning up ==="
rm -f landing-page.tar.gz
echo "✓ Cleanup done"
echo
echo "=== Deployment complete! ==="
echo "Your site should be accessible at: http://49.13.63.29"
