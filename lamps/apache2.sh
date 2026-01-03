#!/bin/bash
# Script para instalar a versão mais recente do PHP disponível no repositório Ondrej PPA.

set -e -o pipefail

echo "Iniciando a instalação e configuração do servidor web com a versão mais recente do PHP..."

# --- Adicionar Repositório PPA do Ondrej para PHP Atualizado ---
echo "Adicionando o repositório PPA do Ondrej para obter a versão mais recente do PHP..."
# Instala pré-requisitos para adicionar repositórios PPA
sudo apt-get install -y software-properties-common curl apt-transport-https lsb-release ca-certificates gnupg2
# Adiciona o PPA e confirma automaticamente
sudo add-apt-repository -y ppa:ondrej/php
# Atualiza a lista de pacotes novamente para incluir os do novo PPA
sudo apt-get update

# --- Instalar pacotes principais (agora com a versão mais recente disponível no PPA) ---
echo "Instalando Apache2, PHP (versão mais recente) e módulos principais..."
sudo apt-get install -y apache2 php libapache2-mod-php

# --- Instalar extensões PHP adicionais (agora para a versão mais recente) ---
echo "Instalando extensões PHP adicionais..."
# Estes pacotes agora se referem à versão mais recente do PHP no PPA
sudo apt-get install -y php-xml php-curl php-opcache php-gd php-sqlite3 php-mbstring php-pgsql php-mysql

# --- Detecção e Configuração (Lógica de detecção anterior ainda funciona) ---
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -c-3)

if [ -z "$PHP_VERSION" ]; then
    echo "Erro: Não foi possível detectar a versão do PHP instalada. Encerrando." >&2
    exit 1
fi

echo "Versão do PHP detectada: $PHP_VERSION"

echo "Configurando módulos do Apache..."
sudo a2dismod mpm_event mpm_worker
sudo a2enmod mpm_prefork rewrite php"$PHP_VERSION"

echo "Reiniciando o serviço Apache para aplicar as mudanças..."
sudo systemctl restart apache2

echo "Instalação e configuração concluídas com sucesso com PHP v$PHP_VERSION!"
