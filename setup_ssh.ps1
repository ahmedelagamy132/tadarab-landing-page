# PowerShell script to set up SSH key on remote server

$server = "49.13.63.29"
$username = "root"
$password = ConvertTo-SecureString "VpTvFhJ4rXnW" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password)

$sshPublicKey = @"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC48/qi9iuf91spSyY27o+hDBbidpcBlx2iym2KRweioXUlETcEuzDXrpu10qqA0Ce76wgIltJSmoeTo6yw+LEAfWhd2PqWAjiTkJSvm/WfK6e+HsuvAw+pfs88HtMU6/6ky+oesqfdT19etOoqbRP/Zl8e2KNE5TGh3VobN7diHCIzefO462WppajyfqYCTXfkaV0pylJ2YL3hvQgMpBj1fDIqboC0HLTTvcP9xTR4rfrwzIsAE45tvvj+0LGgRcL/5giJRj/5Q/3UNOFRSZtpFOTcOdj4BFcAoJOG8YIDB6+kEu0yobp0/EqsGHacyzwpC4MycsOjYRJVeWPSlpshfFIxD5fkQ/8p99jrJuOqd8Hxqag68eb7fRTBzqTsuU1QblNjg6xv8gyjMe80tqdhog10C9DIWUpAkmSWhh0FiTlftPaao2Ft6us/XOs9NGtCwavj2kveTH+XkiawRPFacPiUXNfZwxtCQmWQHHuHCZfRiQgb4B/jerDo/w9IWVwQzYSLlfCyWxyncVpckafizFZISz7ppEm9yedX8dOYpkyxUMF6noDXy5VG33BoEanLWvTdpQwQQRsDIYz3DpJFw3DYncn8C85KzxKUWzwphDVY0Chm/BCXPClxGIkwFnALkwiA5PokgSd4DGeq4FVS/O53WOjx7URK0EBgA7ABmw== ahmed@Agamy
"@

Write-Host "Setting up SSH key on $server..." -ForegroundColor Green

# Create a temporary script to run on the server
$remoteScript = @"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$sshPublicKey" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "SSH key added successfully!"
"@

# Save to temp file
$remoteScript | Out-File -FilePath "remote_setup.sh" -Encoding ASCII -NoNewline

# Use SSH to execute commands
Write-Host "Copying setup script to server..."
scp -o StrictHostKeyChecking=no remote_setup.sh "${username}@${server}:/tmp/"

Write-Host "Executing setup script..."
ssh -o StrictHostKeyChecking=no "${username}@${server}" "bash /tmp/remote_setup.sh"

# Cleanup
Remove-Item remote_setup.sh -Force

Write-Host "SSH key setup complete!" -ForegroundColor Green
Write-Host "You can now run ./deploy.sh to deploy the landing page" -ForegroundColor Yellow
