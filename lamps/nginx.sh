#!/bin/bash

# ==========================================================
# Nginx + PHP (versão mais recente) – Script atualizado
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

echo "Instalando Nginx..."
apt install -y nginx

echo "Instalando PHP e módulos principais..."
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
php-mbstring \
php-xml \
php-zip \
php-bcmath \
php-intl

echo "Habilitando PHP-FPM..."
systemctl enable php-fpm
systemctl start php-fpm

echo "Configurando Nginx para PHP..."
cat <<'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

echo "Testando configuração do Nginx..."
nginx -t

echo "Reiniciando Nginx..."
systemctl restart nginx
systemctl enable nginx

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
echo "Nginx: http://$(hostname -I | awk '{print $1}')"
echo "PHP Info: http://$(hostname -I | awk '{print $1}')/info.php"
echo "Versão do PHP instalada:"
php -v | head -n 1
echo "--------------------------------------------------"
