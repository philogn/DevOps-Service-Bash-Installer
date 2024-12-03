sudo yum update
sudo yum install java-11-openjdk-devel ufw -y
sudo yum install wget unzip -y
sudo service ufw start
sudo service ufw enable
sudo ufw allow 9000

sudo sed -i "$ a vm.max_map_count=262144" /etc/sysctl.conf
sudo sed -i "$ a fs.file-max=65536" /etc/sysctl.conf
sudo sed -i "$ a ulimit -n 65536" /etc/sysctl.conf
sudo sed -i "$ a ulimit -u 4096" /etc/sysctl.conf
sudo sysctl --system

sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum -y install postgresql14-server postgresql14
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable --now postgresql-14

echo 
echo
echo
echo Enter new password for postgres
sudo passwd postgres
echo -n Enter database user name:
read user
echo -n Enter password for user: 
read password
echo -n Enter database name:
read database

su - postgres -c "createuser $user"
sudo -u postgres psql -c "ALTER USER $user WITH ENCRYPTED password '$password';"
sudo -u postgres psql -c "CREATE DATABASE $database OWNER $user;"

sudo yum install -y zip
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.1.46107.zip
sudo unzip sonarqube-9.0.1.46107.zip
sudo mv sonarqube-9.0.1.46107 /opt/sonarqube

sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R

userconf="sonar.jdbc.username=$user"
passwordconf="sonar.jdbc.password=$password"
dbconf="sonar.jdbc.url=jdbc:postgresql://localhost:5432/$database"

sudo sed -i "$ a $userconf" /opt/sonarqube/conf/sonar.properties
sudo sed -i "$ a $passwordconf" /opt/sonarqube/conf/sonar.properties
sudo sed -i "$ a $dbconf" /opt/sonarqube/conf/sonar.properties

sudo sed -i "s/#RUN_AS_USER=/RUN_AS_USER=$user/g" /opt/sonarqube/bin/linux-x86-64/sonar.sh

touch sonar.service
echo "[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target" > sonar.service

sudo mv sonar.service /etc/systemd/system/sonar.service

sudo systemctl enable sonar
sudo systemctl start sonar
sudo systemctl status sonar


