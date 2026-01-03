#!/bin/bash

# ==========================================================
# Apache2 + PHP (versão mais recente) – Script atualizado
# Compatível com Ubuntu 20.04+
# ==========================================================

set -e

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root ou usando sudo."
  exit 1
fi

echo "Atualizando sistema..."
apt update -y
apt upgrade -y

echo "Instalando dependências básicas..."
apt install -y software-properties-common ca-certificates lsb-release apt-transport-https curl

echo "Adicionando repositório PHP (Ondrej)..."
add-apt-repository ppa:ondrej/php -y
apt update -y

echo "Instalando Apache2..."
apt install -y apache2

echo "Instalando PHP e módulos principais..."
apt install -y \
php \
php-cli \
php-common \
libapache2-mod-php \
php-fpm \
php-mysql \
php-pgsql \
php-sqlite3 \
php-curl \
php-gd \
php-mbstring \
php-xml \
php-zip \
php-bcmath \
php-intl

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

echo "Ajustando permissões..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "--------------------------------------------------"
echo "Instalação concluída com sucesso"
echo "Apache: http://SEU_IP/"
echo "PHP Info: http://SEU_IP/info.php"
echo "Versão do PHP instalada:"
php -v
echo "--------------------------------------------------"
