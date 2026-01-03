#!/bin/bash

# ==========================================================
# Script de instalação Apache2 + PHP (última versão)
# Compatível com Ubuntu 20.04+
# ==========================================================

set -e

# Verificação de root
if [ "$EUID" -ne 0 ]; then
  echo "Execute este script como root ou usando sudo."
  exit 1
fi

echo "Atualizando sistema..."
apt update -y
apt upgrade -y

echo "Instalando dependências básicas..."
apt install -y software-properties-common ca-certificates lsb-release apt-transport-https curl

echo "Adicionando PPA do PHP (Ondřej Surý)..."
add-apt-repository ppa:ondrej/php -y
apt update -y

echo "Instalando Apache2..."
apt install -y apache2

echo "Instalando PHP (última versão disponível)..."
apt install -y \
  php \
  php-cli \
  php-common \
  php-fpm \
  php-mysql \
  php-pgsql \
  php-sqlite3 \
  php-curl \
  php-gd \
  php-intl \
  php-mbstring \
  php-xml \
  php-zip \
  php-opcache \
  php-bcmath \
  libapache2-mod-php

echo "Habilitando módulos do Apache..."
a2enmod php
a2enmod rewrite
a2enmod headers

echo "Ajustando prioridade do index.php..."
sed -i 's/index.html/index.php index.html/' /etc/apache2/mods-enabled/dir.conf

echo "Reiniciando Apache..."
systemctl restart apache2
systemctl enable apache2

echo "Criando arquivo de teste PHP..."
cat <<EOF > /var/www/html/info.php
<?php
phpinfo();
?>
EOF

echo "Definindo permissões..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "--------------------------------------------------"
echo "Instalação concluída com sucesso."
echo "Apache: http://SEU_IP/"
echo "PHP Info: http://SEU_IP/info.php"
echo "Versão do PHP instalada:"
php -v
echo "--------------------------------------------------"
