#!/bin/bash

# =================================================================
# Script Name: server-init-hardener.sh
# Description: Automated security hardening and environment setup for AlmaLinux/RHEL.
# Features: SSH Hardening, Firewall Configuration, Fail2ban (Permanent Ban), Docker Installation.
# =================================================================

# --- 1. Global Variables ---
SSH_PORT="2222"
WHITE_LIST="127.0.0.1/8 ::1"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then 
  echo "Error: Please run as root or using sudo."
  exit 1
fi

echo "Starting server initialization..."

# --- 2. System Update & Base Packages ---
echo "Updating system and installing base utilities..."
dnf update -y
dnf install -y epel-release yum-utils curl wget git

# --- 3. Security Components & Docker Installation ---
echo "Installing Firewalld, Fail2ban, Docker, and Cloudflared..."

# Install Firewalld & Fail2ban
dnf install -y firewalld fail2ban fail2ban-firewalld

# Setup Docker Official Repository
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install Cloudflared (Tunnel Engine)
dnf install -y https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm

# Step 4a: Install SELinux management tools (Required for semanage)
echo "Installing SELinux management tools..."
dnf install -y policycoreutils-python-utils

# Step 4b: Update SELinux policy for the new SSH port
# We use || to ensure that if the port is already added, the script won't stop
echo "Updating SELinux policy for Port $SSH_PORT..."
semanage port -a -t ssh_port_t -p tcp $SSH_PORT || semanage port -m -t ssh_port_t -p tcp $SSH_PORT

# Step 4c: Modify SSH configuration files
sed -i -E "s/^#?Port [0-9]+/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i -E "s/^#?PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# Step 4d: Validate SSH config and restart service
sshd -t && systemctl restart sshd

# --- 5. Firewall Configuration ---
echo "Configuring Firewalld rules..."
systemctl enable --now firewalld
firewall-cmd --permanent --add-port=$SSH_PORT/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# --- 6. Fail2ban Configuration (Permanent Ban) ---
echo "Configuring Fail2ban jail.local..."
bash -c "cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
# Permanent ban for attackers (3 attempts within 1 hour)
bantime = -1
findtime = 1h
maxretry = 3
banaction = firewallcmd-ipset
backend = systemd
ignoreip = $WHITE_LIST

[sshd]
enabled = true
port = $SSH_PORT
EOF"

systemctl enable --now fail2ban
systemctl restart fail2ban

# --- 7. Service Activation ---
echo "Enabling Docker engine..."
systemctl enable --now docker

# --- 8. Final Summary ---
echo "------------------------------------------------"
echo "Initialization Complete."
echo "New SSH Port: $SSH_PORT"
echo "Authentication: SSH Key only (Password Disabled)"
echo "Services: Firewalld, Fail2ban, Docker, Cloudflared enabled."
echo "------------------------------------------------"
echo "Warning: Ensure your SSH Key is authorized before disconnecting."
