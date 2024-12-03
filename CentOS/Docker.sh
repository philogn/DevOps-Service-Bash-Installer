sudo yum update
curl -fsSL https://get.docker.com/ | sh

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

sudo docker run hello-world