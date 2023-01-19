#!/bin/bash

# Versão atual do binário do 'docker-compose'
DOCKER_COMPOSE_VERSION="v2.15.1"

# Pacotes para sistemas baseados em Debian
PACKAGES_ARRAY_DEBIAN=(
  "ca-certificates"
  "curl"
  "gnupg"
  "lsb-release"
  "systemd"
)

# Pacotes para sistemas baseados em RedHat
PACKAGES_ARRAY_REDHAT=(
  "yum-utils"
  "ca-certificates"
  "curl"
  "gnupg"
  "redhat-lsb-core"
  "systemd-libs"
)

# Instalando as dependências
case "$(uname -a)" in
  # Caso a distribuição Linux seja o Debian
  *Debian*)
    echo "Instalando as dependências para o sistema Debian..."
    sudo apt-get update && \
    for package in "${PACKAGES_ARRAY_DEBIAN[@]}"; do
      echo "Instalando o pacote '$package'..."
      sudo apt-get install -y $package
    done
    ;;
  # Caso a distribuição Linux seja o Ubuntu
  *Ubuntu*)
    echo "Instalando as dependências para o sistema Ubuntu..."
    sudo apt update && \
    for package in "${PACKAGES_ARRAY_DEBIAN[@]}"; do
      echo "Instalando o pacote '$package'..."
      sudo apt install -y $package
    done
    ;;
  # Caso a distribuição Linux seja o CentOS 7
  *el7*)
    echo "Instalando as dependências para o sistema CentOS 7..."
    sudo yum update -y && \
    for package in "${PACKAGES_ARRAY_REDHAT[@]}"; do
      echo "Instalando o pacote '$package'..."
      sudo yum install -y $package
    done
    ;;
  # Caso a distribuição Linux seja o CentOS 8
  *el8*)
    # Resolvendo o problema dos repositórios no CentOS 8
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    
    echo "Instalando as dependências para o sistema CentOS 8..."
    sudo yum update -y && \
    for package in "${PACKAGES_ARRAY_REDHAT[@]}"; do
      echo "Instalando o pacote '$package'..."
      sudo yum install -y $package
    done
    ;;
  # Caso a distribuição Linux seja outra
  *)
    echo "Sistema não suportado!!"
    exit 1
    ;;
esac

# Instalando o 'docker'
echo "Instalando o 'docker' no seu sistema..."
curl -fsSL https://get.docker.com -o /tmp/docker.sh
sudo sh /tmp/docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker vagrant

# Baixando o binário do 'docker-compose'
echo "Baixando o binário do 'docker-compose'..."
sudo curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose