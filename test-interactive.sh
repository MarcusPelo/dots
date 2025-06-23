#!/bin/bash

# =============================================================================
# 🧪 TESTE DO PROXMOX SETUP SCRIPT INTERATIVO
# =============================================================================
# Script de demonstração/teste do proxmox-setup-interactive.sh
# 
# Este script simula o uso sem fazer alterações reais
# =============================================================================

set -euo pipefail

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

echo -e "${PURPLE}${BOLD}🧪 TESTE DO PROXMOX SETUP SCRIPT INTERATIVO${NC}"
echo -e "${CYAN}=================================================${NC}"
echo

echo -e "${YELLOW}📋 Este script demonstra o uso do proxmox-setup-interactive.sh${NC}"
echo

# Verificar se o script existe
if [[ ! -f "proxmox-setup-interactive.sh" ]]; then
    echo -e "${RED}❌ Script proxmox-setup-interactive.sh não encontrado${NC}"
    echo "   Execute este teste no diretório onde está o script principal"
    exit 1
fi

echo -e "${BLUE}🔍 Verificando informações do script...${NC}"
echo

# Mostrar versão
echo -e "${CYAN}Versão:${NC}"
./proxmox-setup-interactive.sh --version
echo

# Mostrar ajuda
echo -e "${CYAN}Opções disponíveis:${NC}"
./proxmox-setup-interactive.sh --help
echo

# Verificar dependências
echo -e "${BLUE}🔧 Verificando dependências...${NC}"
echo

deps_ok=true

if command -v gum &> /dev/null; then
    echo -e "${GREEN}✅ gum: $(gum --version 2>/dev/null || echo 'instalado')${NC}"
else
    echo -e "${RED}❌ gum: não instalado${NC}"
    deps_ok=false
fi

if command -v fzf &> /dev/null; then
    echo -e "${GREEN}✅ fzf: $(fzf --version 2>/dev/null | cut -d' ' -f1 || echo 'instalado')${NC}"
else
    echo -e "${RED}❌ fzf: não instalado${NC}"
    deps_ok=false
fi

echo

if [[ "$deps_ok" == "true" ]]; then
    echo -e "${GREEN}🎉 Todas as dependências estão instaladas!${NC}"
    echo -e "${CYAN}   Você pode executar o script normalmente:${NC}"
    echo -e "${BOLD}   ./proxmox-setup-interactive.sh${NC}"
    echo
    
    read -p "$(echo -e "${YELLOW}Deseja executar o script agora? (y/N): ${NC}")" -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}🚀 Executando script...${NC}"
        exec ./proxmox-setup-interactive.sh
    fi
else
    echo -e "${YELLOW}⚠️  Dependências ausentes detectadas${NC}"
    echo
    echo -e "${CYAN}📦 Instalação das dependências:${NC}"
    echo
    echo -e "${BOLD}Ubuntu/Debian:${NC}"
    echo "  sudo apt update && sudo apt install fzf"
    echo "  wget https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_x86_64.tar.gz"
    echo "  tar -xzf gum_Linux_x86_64.tar.gz && sudo mv gum /usr/local/bin/"
    echo
    echo -e "${BOLD}Arch Linux:${NC}"
    echo "  sudo pacman -S fzf"
    echo "  yay -S gum"
    echo
    echo -e "${BOLD}RHEL/CentOS/Fedora:${NC}"
    echo "  sudo dnf install fzf"
    echo "  # gum: baixar do GitHub releases"
    echo
    
    read -p "$(echo -e "${YELLOW}Tentar execução mesmo assim (para ver detecção automática)? (y/N): ${NC}")" -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}🔧 O script detectará as dependências ausentes e oferecerá instalação automática...${NC}"
        sleep 2
        exec ./proxmox-setup-interactive.sh
    fi
fi

echo
echo -e "${PURPLE}📚 Documentação completa disponível em:${NC}"
echo -e "${BOLD}   README-proxmox-setup.md${NC}"
echo
echo -e "${GREEN}✨ Obrigado por usar o Proxmox Setup Script!${NC}"
