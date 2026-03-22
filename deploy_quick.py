import paramiko

server = "49.13.63.29"
username = "root"
password = "VpTvFhJ4rXnW"

print("Uploading updated index.html to server...")
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(server, 22, username, password)

sftp = ssh.open_sftp()
sftp.put("index.html", "/var/www/html/index.html")
sftp.close()
ssh.close()

print("Done! File updated.")
print("Visit: http://49.13.63.29")
