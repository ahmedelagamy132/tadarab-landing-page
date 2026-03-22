# SSH Setup Instructions

## Step 1: Add SSH Key to Server

Run this command to add your public SSH key to the server:

```bash
ssh root@49.13.63.29
```

When prompted for password, enter: **VpTvFhJ4rXnW**

Then run these commands on the server:

```bash
mkdir -p ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC48/qi9iuf91spSyY27o+hDBbidpcBlx2iym2KRweioXUlETcEuzDXrpu10qqA0Ce76wgIltJSmoeTo6yw+LEAfWhd2PqWAjiTkJSvm/WfK6e+HsuvAw+pfs88HtMU6/6ky+oesqfdT19etOoqbRP/Zl8e2KNE5TGh3VobN7diHCIzefO462WppajyfqYCTXfkaV0pylJ2YL3hvQgMpBj1fDIqboC0HLTTvcP9xTR4rfrwzIsAE45tvvj+0LGgRcL/5giJRj/5Q/3UNOFRSZtpFOTcOdj4BFcAoJOG8YIDB6+kEu0yobp0/EqsGHacyzwpC4MycsOjYRJVeWPSlpshfFIxD5fkQ/8p99jrJuOqd8Hxqag68eb7fRTBzqTsuU1QblNjg6xv8gyjMe80tqdhog10C9DIWUpAkmSWhh0FiTlftPaao2Ft6us/XOs9NGtCwavj2kveTH+XkiawRPFacPiUXNfZwxtCQmWQHHuHCZfRiQgb4B/jerDo/w9IWVwQzYSLlfCyWxyncVpckafizFZISz7ppEm9yedX8dOYpkyxUMF6noDXy5VG33BoEanLWvTdpQwQQRsDIYz3DpJFw3DYncn8C85KzxKUWzwphDVY0Chm/BCXPClxGIkwFnALkwiA5PokgSd4DGeq4FVS/O53WOjx7URK0EBgA7ABmw== ahmed@Agamy" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
exit
```

## Step 2: Run Deployment Script

Once you've added the SSH key, run the deployment script:

```bash
./deploy.sh
```

The script will:
1. Create an archive of your landing page
2. Copy it to the server
3. Install and configure Nginx web server
4. Deploy your files to /var/www/html/

Your site will be accessible at: **http://49.13.63.29**
