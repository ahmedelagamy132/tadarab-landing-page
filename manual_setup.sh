#!/bin/bash
# Manual SSH setup - copy and run these commands

echo "=========================================="
echo "STEP 1: Connect to server"
echo "=========================================="
echo ""
echo "Run this command:"
echo "  ssh root@49.13.63.29"
echo ""
echo "When prompted for password, enter: VpTvFhJ4rXnW"
echo ""
echo "=========================================="
echo "STEP 2: Run these commands on the server"
echo "=========================================="
echo ""
cat << 'CMDS'
mkdir -p ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC48/qi9iuf91spSyY27o+hDBbidpcBlx2iym2KRweioXUlETcEuzDXrpu10qqA0Ce76wgIltJSmoeTo6yw+LEAfWhd2PqWAjiTkJSvm/WfK6e+HsuvAw+pfs88HtMU6/6ky+oesqfdT19etOoqbRP/Zl8e2KNE5TGh3VobN7diHCIzefO462WppajyfqYCTXfkaV0pylJ2YL3hvQgMpBj1fDIqboC0HLTTvcP9xTR4rfrwzIsAE45tvvj+0LGgRcL/5giJRj/5Q/3UNOFRSZtpFOTcOdj4BFcAoJOG8YIDB6+kEu0yobp0/EqsGHacyzwpC4MycsOjYRJVeWPSlpshfFIxD5fkQ/8p99jrJuOqd8Hxqag68eb7fRTBzqTsuU1QblNjg6xv8gyjMe80tqdhog10C9DIWUpAkmSWhh0FiTlftPaao2Ft6us/XOs9NGtCwavj2kveTH+XkiawRPFacPiUXNfZwxtCQmWQHHuHCZfRiQgb4B/jerDo/w9IWVwQzYSLlfCyWxyncVpckafizFZISz7ppEm9yedX8dOYpkyxUMF6noDXy5VG33BoEanLWvTdpQwQQRsDIYz3DpJFw3DYncn8C85KzxKUWzwphDVY0Chm/BCXPClxGIkwFnALkwiA5PokgSd4DGeq4FVS/O53WOjx7URK0EBgA7ABmw== ahmed@Agamy" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
exit
CMDS
echo ""
echo "=========================================="
echo "STEP 3: Run deployment script"
echo "=========================================="
echo ""
echo "After setting up the SSH key, run:"
echo "  ./deploy.sh"
echo ""
