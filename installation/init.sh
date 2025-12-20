#!/bin/bash

# This script is used to prepare the Linux environment for the openGauss installation
# It has been tested on openEuler 22.03 and runs perfectly without issues

# Disable SELINUX
echo "Disabling SELINUX..."
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
echo "SELINUX disabled. System will be rebooted."

# Disable Firewall (if active)
echo "Checking firewall status..."
FIREWALL_STATUS=$(systemctl is-active firewalld)

if [ "$FIREWALL_STATUS" == "active" ]; then
echo "Firewall is running. Disabling firewall..."
systemctl disable firewalld.service
systemctl stop firewalld.service
else
echo "Firewall is already inactive."
fi

# Set Character Set Parameters
echo "Setting character set parameters..."
echo "export LANG=en_US.UTF-8" >> /etc/profile

# Disable Swap Memory
echo "Disabling swap memory..."
swapoff -a

# Disabling RemoveIPC
echo "Disabling RemoveIPC..."
sed -i 's/^#RemoveIPC=no/RemoveIPC=no/' /etc/systemd/logind.conf
sed -i 's/^RemoveIPC=yes/RemoveIPC=no/' /usr/lib/systemd/system/systemd-logind.service

# Reload systemd configuration
systemctl daemon-reload
systemctl restart systemd-logind

# Verify RemoveIPC setting
echo "Verifying RemoveIPC setting..."
loginctl show-session | grep RemoveIPC
systemctl show systemd-logind | grep RemoveIPC

# Disable History Command
echo "Disabling history command..."
sed -i 's/^HISTSIZE=.*/HISTSIZE=0/' /etc/profile
source /etc/profile

# Enable Remote Login for Root
echo "Enabling remote login for root..."
sed -i 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config

# Disable SSH Banner
echo "Disabling SSH banner..."
sed -i 's/^#Banner/Banner/' /etc/ssh/sshd_config
sed -i 's/^Banner .*/#Banner/' /etc/ssh/sshd_config

# Restart SSH service
echo "Restarting SSH service..."
systemctl restart sshd.service

# Modify python and install libaio
mv /usr/bin/python /usr/bin/python.bak
ln -s /usr/bin/python3 /usr/bin/python
python -V
yum install libaio* -y
yum install tar  -y
yum install expect  -y

echo "Script execution complete."

reboot

