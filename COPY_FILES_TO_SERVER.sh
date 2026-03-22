#!/bin/bash
# Run this on YOUR LOCAL MACHINE to copy files to server

SERVER="49.13.63.29"
USER="root"
DEST="/var/www/html"

echo "=========================================="
echo "Copying landing page files to server"
echo "=========================================="
echo

# Copy index.html
echo "1. Copying index.html..."
scp index.html ${USER}@${SERVER}:${DEST}/

# Copy assets folder
echo "2. Copying assets folder..."
scp -r assets/ ${USER}@${SERVER}:${DEST}/

# Set correct permissions
echo "3. Setting permissions..."
ssh ${USER}@${SERVER} "chown -R www-data:www-data ${DEST} && chmod -R 755 ${DEST}"

echo
echo "=========================================="
echo "Files copied successfully!"
echo "=========================================="
echo
echo "Your site is now available at: http://49.13.63.29"
echo
