#!/bin/bash

# Script para copiar a chave SSH para o servidor Proxmox
# Uso: ./setup-proxmox-ssh.sh IP_DO_SERVIDOR

if [ $# -eq 0 ]; then
    echo "❌ Erro: Por favor, forneça o IP do servidor Proxmox"
    echo "Uso: $0 IP_DO_SERVIDOR"
    echo "Exemplo: $0 192.168.1.100"
    exit 1
fi

PROXMOX_IP=$1
SSH_KEY="$HOME/.ssh/proxmox_key.pub"

echo "🔑 Configurando acesso SSH para Proxmox..."
echo "📍 Servidor: $PROXMOX_IP"
echo "🔐 Chave: $SSH_KEY"
echo ""

# Verificar se a chave existe
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Erro: Chave SSH não encontrada em $SSH_KEY"
    exit 1
fi

echo "📋 Sua chave pública:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$SSH_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🚀 Tentando copiar a chave para o servidor..."
echo "   (Você precisará inserir a senha do root do Proxmox)"

# Tentar usar ssh-copy-id
if command -v ssh-copy-id >/dev/null 2>&1; then
    ssh-copy-id -i "$SSH_KEY" root@"$PROXMOX_IP"
    if [ $? -eq 0 ]; then
        echo "✅ Chave copiada com sucesso!"
        
        # Atualizar o arquivo de configuração SSH
        sed -i "s/IP_DO_SEU_PROXMOX/$PROXMOX_IP/g" "$HOME/.ssh/config"
        
        echo "⚙️  Configuração SSH atualizada em ~/.ssh/config"
        echo ""
        echo "🎉 Agora você pode acessar o Proxmox simplesmente com:"
        echo "   ssh proxmox"
        echo ""
        echo "🧪 Testando a conexão..."
        ssh -o ConnectTimeout=5 proxmox "echo '✅ Conexão SSH funcionando perfeitamente!'"
    else
        echo "❌ Erro ao copiar a chave. Tente o método manual abaixo."
    fi
else
    echo "⚠️  ssh-copy-id não encontrado. Use o método manual:"
fi

echo ""
echo "📝 MÉTODO MANUAL:"
echo "1. Copie a chave pública mostrada acima"
echo "2. Acesse seu servidor Proxmox via SSH:"
echo "   ssh root@$PROXMOX_IP"
echo "3. Execute os comandos:"
echo "   mkdir -p ~/.ssh"
echo "   echo 'SUA_CHAVE_PUBLICA_AQUI' >> ~/.ssh/authorized_keys"
echo "   chmod 700 ~/.ssh"
echo "   chmod 600 ~/.ssh/authorized_keys"
echo ""
echo "4. Edite o arquivo ~/.ssh/config e substitua IP_DO_SEU_PROXMOX por $PROXMOX_IP"
