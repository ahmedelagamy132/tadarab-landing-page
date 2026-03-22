# Complete Setup Guide for Landing Page Hosting

## Problem: Server not responding (ERR_CONNECTION_REFUSED)

This means nginx is not installed or running on the server. Follow these steps to fix it:

---

## Step 1: Connect to Server

Open your terminal/command prompt and run:

```bash
ssh root@49.13.63.29
```

**Password:** `VpTvFhJ4rXnW`

---

## Step 2: Run Server Setup Script (ON SERVER)

Once connected to the server, copy and paste this entire command block:

```bash
apt-get update && \
apt-get install -y nginx && \
systemctl start nginx && \
systemctl enable nginx && \
mkdir -p /var/www/html && \
cat > /etc/nginx/sites-available/landing-page << 'NGINXCONF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html;
    server_name _;
    location / {
        try_files $uri $uri/ =404;
    }
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|webp|woff|woff2|mp4)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
NGINXCONF
rm -f /etc/nginx/sites-enabled/default && \
ln -s /etc/nginx/sites-available/landing-page /etc/nginx/sites-enabled/landing-page && \
nginx -t && \
systemctl restart nginx && \
echo "==========================================
Server setup complete!
Nginx is now running on http://49.13.63.29
==========================================" || echo "Error occurred!"
```

---

## Step 3: Verify Nginx is Running

After running the setup script, check nginx status:

```bash
systemctl status nginx
```

You should see:
- `Active: active (running)`

Now test in your browser: **http://49.13.63.29**
You should see "Welcome to nginx!" page.

---

## Step 4: Copy Landing Page Files

**Option A: Using SCP (From your LOCAL machine in the landing-v3 directory):**

```bash
scp index.html root@49.13.63.29:/var/www/html/
scp -r assets/ root@49.13.63.29:/var/www/html/
```

**Option B: Using SFTP client (like FileZilla):**

1. Connect to `49.13.63.29` with user `root` and password `VpTvFhJ4rXnW`
2. Navigate to `/var/www/html/`
3. Upload `index.html` and the `assets/` folder

**Option C: Directly on server:**

Upload your files to a service, then on server:

```bash
cd /var/www/html
# Download your files (replace URL with actual file URL)
wget YOUR_FILE_URL
```

---

## Step 5: Set Permissions

On the server, run:

```bash
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```

---

## Step 6: Verify Deployment

Visit: **http://49.13.63.29**

You should see your landing page!

---

## Troubleshooting

### If still getting ERR_CONNECTION_REFUSED:

1. Check if nginx is running:
   ```bash
   systemctl status nginx
   ```

2. If not running, start it:
   ```bash
   systemctl start nginx
   systemctl enable nginx
   ```

3. Check if port 80 is open:
   ```bash
   ufw status
   ```
   If inactive or port 80 not allowed, run:
   ```bash
   ufw allow 80/tcp
   ufw allow 80
   ufw enable
   ```

4. Check nginx error logs:
   ```bash
   tail -f /var/log/nginx/error.log
   ```

### If seeing "Welcome to nginx!":

The web server is working, but your files aren't uploaded yet. Complete Step 4.

### If getting 403 Forbidden:

Permissions issue, run Step 5 to fix permissions.

---

## Files in Your Project

I've created helper scripts:

- `DEPLOY_MANUALLY_ON_SERVER.sh` - Run this on the server
- `COPY_FILES_TO_SERVER.sh` - Run this locally to copy files

But you can also just follow the manual commands above.
