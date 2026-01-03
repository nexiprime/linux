#!/bin/bash
echo -e "\e[32m"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                _                 _                         ║"
echo "║          _   _| |__  _   _ _ __ | |_ _   _                 ║"
echo "║         | | | | '_ \| | | | '_ \| __| | | |                ║"
echo "║         | |_| | |_) | |_| | | | | |_| |_| |                ║"
echo "║          \__,_|_.__/ \__,_|_| |_|\__|\__,_|                ║"
echo "║                                                            ║"
echo "║               RESET DO SERVIDOR SSH                        ║"
echo "║                                                            ║"
echo "║  [*] Iniciando reset do servidor ssh...                    ║"
echo "║  [*] Sistema: Ubuntu $(lsb_release -rs)                                 ║"
echo "║  [*] Data: $(date)                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "\e[0m"
sleep 3

# Atualizando o sistema
echo -e "\e[32m"
echo " [*] ATUALIZANDO O SISTEMA..."
echo -e "\e[0m"
sleep 5
apt update && apt upgrade -y

sleep 2

# Parar o serviço do ssh
echo -e "\e[32m"
echo " [*] PARANDO O SERVIÇO DO SSH..."
echo -e "\e[0m"
sleep 5
systemctl stop ssh
systemctl stop sshd

sleep 2

# Remover pacote Openssh-server e Openssh-cliente
echo -e "\e[32m"
echo " [*] REMOVENDO PACOTE OPENSHE-SERVER E OPENSHE-CLIENTE..."
echo -e "\e[0m"
sleep 5
apt remove --purge openssh-server openssh-client -y

sleep 2

# Deletar arquivo de configuração do ssh
echo -e "\e[32m"
echo " [*] DELETANDO ARQUIVO DE CONFIGURAÇÃO DO SSH..."
echo -e "\e[0m"
sleep 5
rm -rf /etc/ssh

sleep 2

# Limpar cache do sistemas
echo -e "\e[32m"
echo " [*] LIMPAR CACHE DO SISTEMA..."
echo -e "\e[0m"
sleep 5
apt autoremove -y

sleep 2

# Instalar pacote Openssh-server e Openssh-cliente
echo -e "\e[32m"
echo " [*] INSTALANDO PACOTE OPENSHE-SERVER E OPENSHE-CLIENTE..."
echo -e "\e[0m"
sleep 5
apt install openssh-server openssh-client -y

sleep 2

read -r -p "Deseja ativar o usuario ssh root? (Y/N): " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    
    echo -e "\e[32m[*] Digite a nova senha para o root:\e[0m"
    read -r -s -p "Senha: " root_pass
    echo ""
    echo "root:$root_pass" | sudo chpasswd
    
    echo -e "\e[32m[*] Senha configurada e permissões de root aplicadas...\e[0m"
elif [[ $resposta =~ ^[Nn]$ ]]; then
    echo "Operação cancelada"
else
    echo "Resposta inválida. Use Y para sim ou N para não."
fi

sleep 2 

# Reiniciar o serviço do ssh
echo -e "\e[32m"
echo " [*] REINICIANDO O SERVIÇO DO SSH..."
echo -e "\e[0m"
sleep 5
systemctl restart ssh
systemctl restart sshd

sleep 2

# Finalizar o script
echo -e "\e[32m"
echo " [*] SCRIPT FINALIZADO..."
echo -e "\e[0m"
sleep 2
exit 0