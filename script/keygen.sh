#!/bin/bash

# Garante que a pasta .ssh existe com permissões corretas
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

echo "O que você deseja fazer?"
echo "1) Gerar uma nova chave SSH"
echo "2) Importar uma chave pública (.pub) existente"
read -p "Escolha uma opção (1 ou 2): " OPCAO

if [ "$OPCAO" == "1" ]; then
    # --- OPÇÃO 1: GERAR NOVA ---
    read -p "Digite o nome para a nova chave (ex: id_ed25519_notebook): " KEY_NAME
    KEY_PATH="$HOME/.ssh/$KEY_NAME"
    
    # Gera a chave (Ed25519)
    ssh-keygen -t ed25519 -f "$KEY_PATH" -C "acesso_notebook_2026"
    
    # Adiciona ao authorized_keys
    cat "$KEY_PATH.pub" >> "$HOME/.ssh/authorized_keys"
    echo "Nova chave gerada e autorizada."

elif [ "$OPCAO" == "2" ]; then
    # --- OPÇÃO 2: IMPORTAR ---
    read -p "Digite o caminho completo do arquivo .pub (ex: /media/user/pendrive/chave.pub): " PUB_PATH
    
    if [ -f "$PUB_PATH" ]; then
        cat "$PUB_PATH" >> "$HOME/.ssh/authorized_keys"
        echo "Chave importada com sucesso para o authorized_keys."
    else
        echo "Erro: Arquivo não encontrado no caminho: $PUB_PATH"
        exit 1
    fi
else
    echo "Opção inválida."
    exit 1
fi

# Ajusta permissões finais por segurança
chmod 600 "$HOME/.ssh/authorized_keys"
echo "-------------------------------------------------------"
echo "Configuração concluída em 2026!"
echo "Certifique-se de que o serviço SSH está rodando (sudo systemctl start ssh)."
echo "-------------------------------------------------------"
