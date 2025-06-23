#!/bin/bash

# =============================================================================
# 📦 CONFIGURADOR DE AMBIENTE PARA PROXMOX SETUP
# =============================================================================
# Script para configurar o ambiente e instalar dependências necessárias
# para o proxmox-setup-interactive.sh
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

# Função para mostrar header
show_header() {
    clear
    echo -e "${PURPLE}${BOLD}
╔══════════════════════════════════════════════════════════════════╗
║                    🚀 PROXMOX SETUP CONFIGURATOR                ║
║                                                                  ║
║              Configuração de ambiente e dependências            ║
╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Função para logging
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO")  echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "STEP") echo -e "${CYAN}🔸 $message${NC}" ;;
    esac
}

# Detectar sistema operacional
detect_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# Detectar arquitetura
detect_arch() {
    case "$(uname -m)" in
        x86_64) echo "x86_64" ;;
        aarch64|arm64) echo "arm64" ;;
        armv7l) echo "armv6" ;;
        *) echo "x86_64" ;;
    esac
}

# Instalar fzf
install_fzf() {
    local os_type="$1"
    
    log "STEP" "Instalando fzf..."
    
    case "$os_type" in
        "ubuntu"|"debian")
            sudo apt update && sudo apt install -y fzf
            ;;
        "fedora"|"rhel"|"centos")
            if command -v dnf &> /dev/null; then
                sudo dnf install -y fzf
            else
                sudo yum install -y fzf
            fi
            ;;
        "arch"|"manjaro")
            sudo pacman -S --noconfirm fzf
            ;;
        *)
            log "WARNING" "Sistema não reconhecido, tentando instalação manual..."
            if [[ ! -d "$HOME/.fzf" ]]; then
                git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
                "$HOME/.fzf/install" --all --no-bash --no-fish
            fi
            ;;
    esac
    
    log "SUCCESS" "fzf instalado"
}

# Instalar gum
install_gum() {
    local arch="$1"
    
    log "STEP" "Instalando gum..."
    
    # URL para download
    local gum_url="https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_${arch}.tar.gz"
    
    # Baixar e instalar
    wget -q "$gum_url" -O /tmp/gum.tar.gz
    tar -xzf /tmp/gum.tar.gz -C /tmp/
    sudo mv /tmp/gum /usr/local/bin/
    sudo chmod +x /usr/local/bin/gum
    rm -f /tmp/gum.tar.gz
    
    log "SUCCESS" "gum instalado"
}

# Verificar e instalar dependências
setup_dependencies() {
    local os_type
    local arch
    
    os_type=$(detect_os)
    arch=$(detect_arch)
    
    log "INFO" "Sistema detectado: $os_type ($arch)"
    echo
    
    # Verificar fzf
    if command -v fzf &> /dev/null; then
        log "SUCCESS" "fzf já está instalado: $(fzf --version | cut -d' ' -f1)"
    else
        install_fzf "$os_type"
    fi
    
    # Verificar gum
    if command -v gum &> /dev/null; then
        log "SUCCESS" "gum já está instalado: $(gum --version)"
    else
        install_gum "$arch"
    fi
}

# Configurar ambiente
setup_environment() {
    log "STEP" "Configurando ambiente..."
    
    # Criar diretórios necessários
    mkdir -p "$HOME/.proxmox-setup/backups"
    
    # Tornar scripts executáveis
    if [[ -f "proxmox-setup-interactive.sh" ]]; then
        chmod +x proxmox-setup-interactive.sh
        log "SUCCESS" "proxmox-setup-interactive.sh configurado"
    fi
    
    if [[ -f "test-interactive.sh" ]]; then
        chmod +x test-interactive.sh
        log "SUCCESS" "test-interactive.sh configurado"
    fi
    
    log "SUCCESS" "Ambiente configurado"
}

# Testar instalação
test_setup() {
    log "STEP" "Testando configuração..."
    echo
    
    # Testar fzf
    if command -v fzf &> /dev/null; then
        echo -e "${GREEN}✅ fzf: $(fzf --version | cut -d' ' -f1)${NC}"
    else
        echo -e "${RED}❌ fzf: não encontrado${NC}"
        return 1
    fi
    
    # Testar gum
    if command -v gum &> /dev/null; then
        echo -e "${GREEN}✅ gum: $(gum --version)${NC}"
    else
        echo -e "${RED}❌ gum: não encontrado${NC}"
        return 1
    fi
    
    # Testar script principal
    if [[ -x "proxmox-setup-interactive.sh" ]]; then
        echo -e "${GREEN}✅ proxmox-setup-interactive.sh: executável${NC}"
    else
        echo -e "${RED}❌ proxmox-setup-interactive.sh: não encontrado ou não executável${NC}"
        return 1
    fi
    
    echo
    log "SUCCESS" "Todos os testes passaram!"
}

# Mostrar instruções finais
show_final_instructions() {
    echo
    echo -e "${PURPLE}${BOLD}🎉 CONFIGURAÇÃO CONCLUÍDA!${NC}"
    echo
    echo -e "${CYAN}📋 Próximos passos:${NC}"
    echo
    echo -e "${YELLOW}1. Execute o script principal:${NC}"
    echo -e "   ${BOLD}./proxmox-setup-interactive.sh${NC}"
    echo
    echo -e "${YELLOW}2. Ou teste primeiro:${NC}"
    echo -e "   ${BOLD}./test-interactive.sh${NC}"
    echo
    echo -e "${YELLOW}3. Para ajuda:${NC}"
    echo -e "   ${BOLD}./proxmox-setup-interactive.sh --help${NC}"
    echo
    echo -e "${CYAN}📚 Documentação:${NC}"
    echo -e "   ${BOLD}README-proxmox-setup.md${NC}"
    echo
    echo -e "${GREEN}✨ Tudo pronto para configurar seu ambiente Proxmox!${NC}"
}

# Função principal
main() {
    show_header
    
    log "INFO" "Iniciando configuração do ambiente..."
    echo
    
    # Verificar se está no diretório correto
    if [[ ! -f "proxmox-setup-interactive.sh" ]]; then
        log "ERROR" "Script proxmox-setup-interactive.sh não encontrado"
        log "INFO" "Execute este script no diretório onde estão os arquivos do projeto"
        exit 1
    fi
    
    # Configurar dependências
    setup_dependencies
    echo
    
    # Configurar ambiente
    setup_environment
    echo
    
    # Testar configuração
    if test_setup; then
        show_final_instructions
    else
        log "ERROR" "Falha na configuração. Verifique os erros acima."
        exit 1
    fi
}

# Executar se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
