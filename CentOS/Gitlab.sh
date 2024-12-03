sudo yum update
sudo yum install -y curl policycoreutils-python postfix ca-certificates
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum -y install gitlab-ce

echo
echo
echo
echo
echo

echo -n Enter your domain name: http://
read Domain
echo -n Enter your ip address: 
read ip
config="$ip	$Domain"
sudo sed -i "s/gitlab.example.com/$Domain/" /etc/gitlab/gitlab.rb 
sudo sed -i "$ a $config" /etc/hosts
sudo gitlab-ctl reconfigure