#!/bin/bash

# Script para fazer backup das chaves SSH
BACKUP_DIR="$HOME/ssh-backup-$(date +%Y%m%d)"
SSH_DIR="$HOME/.ssh"

echo "🔐 Fazendo backup das chaves SSH..."
echo "📁 Diretório de backup: $BACKUP_DIR"

# Criar diretório de backup
mkdir -p "$BACKUP_DIR"

# Copiar arquivos importantes
if [ -d "$SSH_DIR" ]; then
    cp -r "$SSH_DIR"/* "$BACKUP_DIR/"
    echo "✅ Backup concluído!"
    echo "📋 Arquivos salvos:"
    ls -la "$BACKUP_DIR"
else
    echo "❌ Diretório SSH não encontrado!"
    exit 1
fi

echo ""
echo "💡 Para restaurar o backup, execute:"
echo "   cp -r $BACKUP_DIR/* ~/.ssh/"
echo "   chmod 700 ~/.ssh"
echo "   chmod 600 ~/.ssh/*"
