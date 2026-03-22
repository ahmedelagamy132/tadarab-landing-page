#!/bin/bash
# Run this script ON THE SERVER after connecting with: ssh root@49.13.63.29

echo "=========================================="
echo "Setting up web server for landing page"
echo "=========================================="
echo

# Update packages
echo "1. Updating packages..."
apt-get update -y
apt-get upgrade -y

# Install nginx
echo "2. Installing nginx..."
apt-get install -y nginx

# Start nginx
echo "3. Starting nginx..."
systemctl start nginx
systemctl enable nginx

# Backup existing site
echo "4. Backing up existing site (if any)..."
if [ -d /var/www/html ]; then
  cp -r /var/www/html /var/www/html.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
fi

# Create directory
mkdir -p /var/www/html

# Configure nginx for our site
echo "5. Configuring nginx..."
cat > /etc/nginx/sites-available/landing-page << 'NGINXCONFIG'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Cache static assets for 30 days
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|webp|woff|woff2|mp4)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
NGINXCONFIG

# Enable the site
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/landing-page /etc/nginx/sites-enabled/landing-page

# Test nginx configuration
echo "6. Testing nginx configuration..."
nginx -t

# Restart nginx
echo "7. Restarting nginx..."
systemctl restart nginx

echo
echo "=========================================="
echo "Server setup complete!"
echo "=========================================="
echo
echo "Your server is ready to receive files."
echo "Now copy your files from local machine:"
echo "  scp -r index.html assets/ root@49.13.63.29:/var/www/html/"
echo
echo "Or upload files to: /var/www/html/"
echo
echo "Your site will be available at: http://49.13.63.29"
echo
