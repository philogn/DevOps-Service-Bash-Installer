sudo apt update
sudo apt install openjdk-8-jdk ufw -y
sudo ufw allow 8081
sudo ufw enable

cd /opt
sudo wget http://download.sonatype.com/nexus/3/nexus-3.59.0-01-unix.tar.gz
sudo tar -zxvf nexus-3.59.0-01-unix.tar.gz
sudo mv /opt/nexus-3.59.0-01 /opt/nexus

echo -n Enter password for nexus user:
sudo adduser nexus
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

sudo sed -i '$ a run_as_user="nexus"' /opt/nexus/bin/nexus.rc
sudo sed -i "1d" /opt/nexus/bin/nexus.rc
sudo ln -s /opt/nexus/bin/nexus /etc/init.d/nexus

sudo sed -i 's/2703/1024/g' /opt/nexus/bin/nexus.vmoptions

cd
touch nexus.service
echo '[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/etc/init.d/nexus start
ExecStop=/etc/init.d/nexus stop 
User=nexus
Restart=on-abort
TimeoutSec=600
  
[Install]
WantedBy=multi-user.target' > nexus.service
sudo mv nexus.service /etc/systemd/system/nexus.service

sudo systemctl enable nexus
sudo systemctl start nexus
