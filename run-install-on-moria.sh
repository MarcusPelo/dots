#!/bin/bash

# Script para copiar e executar a instalação no servidor Proxmox
echo "🚀 Transferindo e executando instalação no servidor Moria..."

# Copiar script para o servidor
echo "📤 Copiando script de instalação..."
scp /home/marcus/install-zsh-proxmox.sh moria:/tmp/

# Executar no servidor
echo "⚡ Executando instalação no servidor..."
ssh moria "chmod +x /tmp/install-zsh-proxmox.sh && /tmp/install-zsh-proxmox.sh"

echo "✅ Instalação concluída!"
echo ""
echo "🔄 Para aplicar as configurações, faça login no servidor:"
echo "   ssh moria"
echo ""
echo "⚙️  Depois execute:"
echo "   source ~/.zshrc"
echo "   p10k configure  # Para configurar o tema"
