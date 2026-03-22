import paramiko
import time

server = "49.13.63.29"
username = "root"
password = "VpTvFhJ4rXnW"

print("=== Uploading and Verifying ===")
print()

# Connect to server
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(server, 22, username, password)

# Upload file
print("1. Uploading index.html...")
sftp = ssh.open_sftp()
sftp.put("index.html", "/var/www/html/index.html")
sftp.close()
print("   File uploaded")

# Clear browser cache by touching file
print("2. Touching file to update timestamp...")
ssh.exec_command("touch /var/www/html/index.html")

# Restart nginx to ensure changes take effect
print("3. Restarting nginx...")
stdin, stdout, stderr = ssh.exec_command("systemctl reload nginx")
print("   Nginx reloaded")

# Verify file is updated
print("4. Verifying changes on server...")
time.sleep(1)
stdin, stdout, stderr = ssh.exec_command("grep -A 3 '@media (max-width: 767px)' /var/www/html/index.html | grep 'nav-btn'")
nav_btn_result = stdout.read().decode().strip()

stdin, stdout, stderr = ssh.exec_command("grep -A 3 '@media (max-width: 767px)' /var/www/html/index.html | grep 'inst2-photo-name'")
photo_name_result = stdout.read().decode().strip()

print()
print("=== VERIFICATION RESULTS ===")
print()

if "width: 100%" in nav_btn_result:
    print("[OK] nav-btn has width: 100%")
else:
    print("[FAIL] nav-btn width not found")
    print(f"  Found: {nav_btn_result}")

if "text-align: center" in photo_name_result:
    print("[OK] inst2-photo-name has text-align: center")
else:
    print("[FAIL] inst2-photo-name text-align not found")
    print(f"  Found: {photo_name_result}")

print()
print("=== DONE ===")
print()
print(f"Visit: http://{server}")
print()
print("NOTE: If changes don't appear, try:")
print("  1. Hard refresh: Ctrl+Shift+R")
print("  2. Clear browser cache")
print("  3. Open in Incognito/Private mode")

ssh.close()
