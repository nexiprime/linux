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
    echo "[*] Ativando login SSH como root com senha..."

    # Garantir diretivas corretas no sshd_config (independente do estado atual)
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config

    # Pedir senha duas vezes (evita erro de digitação)
    while true; do
        read -r -s -p "Digite a nova senha do root: " root_pass1
        echo ""
        read -r -s -p "Confirme a nova senha do root: " root_pass2
        echo ""

        if [[ "$root_pass1" == "$root_pass2" && -n "$root_pass1" ]]; then
            break
        else
            echo "As senhas não conferem ou estão vazias. Tente novamente."
        fi
    done

    # Aplicar senha corretamente
    echo "root:$root_pass1" | chpasswd

    # DESBLOQUEAR o usuário root (PASSO CRÍTICO)
    passwd -u root >/dev/null 2>&1

    # Garantir shell válida
    usermod -s /bin/bash root

    echo "[✓] SSH root habilitado com senha ativa."
elif [[ $resposta =~ ^[Nn]$ ]]; then
    echo "Ativação de SSH root ignorada."
else
    echo "Resposta inválida. Use Y ou N."
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