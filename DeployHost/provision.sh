#!/bin/bash

adduser deploy
echo "deploy:jenkins" | chpasswd
groupadd train-schedule
usermod -a -G train-schedule deploy
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/#PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop train-schedule" >> /etc/sudoers
echo "deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl start train-schedule" >> /etc/sudoers
echo -e "[Unit]\\nDescription=Train Schedule\\nAfter=network.target\\n\\n[Service]\\n\\nType=simple\\nWorkingDirectory=/opt/train-schedule\\nExecStart=/usr/bin/node bin/www\\nStandardOutput=syslog\\nStandardError=syslog\\nRestart=on-failure\\n\\n[Install]\\nWantedBy=multi-user.target" > /etc/systemd/system/train-schedule.service
/usr/bin/systemctl daemon-reload
mkdir -p /opt/train-schedule
chown root:train-schedule /opt/train-schedule
chmod 775 /opt/train-schedule/
sudo yum install -y epel-release
sudo yum install -y nodejs
sudo yum install -y unzip

sudo yum -y install docker
sudo systemctl start docker
sudo systemctl enable docker
sudo groupadd docker
#sudo usermod -aG docker jenkins
sudo usermod -aG docker deploy
sudo systemctl restart docker

#Changed ssh login allow in sshd service config
echo "Success"

