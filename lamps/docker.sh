#!/bin/bash

# 1. Remove pacotes antigos ou conflitantes
echo "Limpando versões antigas..."
sudo apt-get remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc

# 2. Atualiza e instala pré-requisitos
echo "Instalando pré-requisitos..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# 3. Configura a chave GPG oficial do Docker
echo "Configurando repositório..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 4. Adiciona o repositório oficial às fontes do APT
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# 5. Instala o Docker e plugins
echo "Instalando Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Verifica a instalação
sudo docker --version
echo "Instalação concluída com sucesso!"
