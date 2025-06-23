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
    local os_type="$1"
    local arch="$2"
    
    log "STEP" "Instalando gum..."
    
    # Tentar métodos de instalação por ordem de preferência
    case "$os_type" in
        "ubuntu"|"debian")
            log "INFO" "Tentando instalação via repositório Debian..."
            if install_gum_debian; then
                log "SUCCESS" "gum instalado via repositório Debian"
                return 0
            fi
            log "WARNING" "Falha na instalação via repositório, tentando método manual..."
            ;;
        "fedora"|"rhel"|"centos")
            log "INFO" "Tentando instalação via repositório RPM..."
            if install_gum_rpm; then
                log "SUCCESS" "gum instalado via repositório RPM"
                return 0
            fi
            log "WARNING" "Falha na instalação via repositório, tentando método manual..."
            ;;
        "arch"|"manjaro")
            log "INFO" "Tentando instalação via AUR..."
            if install_gum_arch; then
                log "SUCCESS" "gum instalado via AUR"
                return 0
            fi
            log "WARNING" "Falha na instalação via AUR, tentando método manual..."
            ;;
    esac
    
    # Método manual como fallback
    log "INFO" "Tentando instalação manual..."
    if install_gum_manual "$arch"; then
        log "SUCCESS" "gum instalado via método manual"
    else
        log "ERROR" "Falha na instalação do gum"
        return 1
    fi
}

# Instalar gum via repositório Debian/Ubuntu
install_gum_debian() {
    if ! command -v curl &> /dev/null; then
        sudo apt update && sudo apt install -y curl
    fi
    
    # Adicionar repositório e instalar
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update && sudo apt install -y gum
}

# Instalar gum via repositório RPM (Fedora/RHEL/CentOS)
install_gum_rpm() {
    if command -v dnf &> /dev/null; then
        echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
        sudo dnf install -y gum
    elif command -v yum &> /dev/null; then
        echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
        sudo yum install -y gum
    else
        return 1
    fi
}

# Instalar gum via AUR (Arch Linux)
install_gum_arch() {
    if command -v yay &> /dev/null; then
        yay -S --noconfirm gum
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm gum
    else
        # Tentar pacman (se estiver nos repositórios oficiais)
        sudo pacman -S --noconfirm gum 2>/dev/null || return 1
    fi
}

# Instalar gum manualmente via GitHub releases
install_gum_manual() {
    local arch="$1"
    
    # Verificar dependências
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        log "ERROR" "curl ou wget é necessário para instalação manual"
        return 1
    fi
    
    # Detectar versão mais recente
    log "INFO" "Detectando versão mais recente do gum..."
    local latest_version
    if command -v curl &> /dev/null; then
        latest_version=$(curl -s https://api.github.com/repos/charmbracelet/gum/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        latest_version=$(wget -qO- https://api.github.com/repos/charmbracelet/gum/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    fi
    
    if [[ -z "$latest_version" ]]; then
        log "WARNING" "Não foi possível detectar a versão, usando 'latest'"
        latest_version="latest"
    else
        log "INFO" "Versão detectada: $latest_version"
    fi
    
    # URL para download
    local gum_url
    if [[ "$latest_version" == "latest" ]]; then
        gum_url="https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_${arch}.tar.gz"
    else
        gum_url="https://github.com/charmbracelet/gum/releases/download/${latest_version}/gum_Linux_${arch}.tar.gz"
    fi
    
    log "INFO" "Baixando de: $gum_url"
    
    # Criar diretório temporário
    local temp_dir=$(mktemp -d)
    local gum_archive="$temp_dir/gum.tar.gz"
    
    # Baixar arquivo
    if command -v curl &> /dev/null; then
        if ! curl -fsSL "$gum_url" -o "$gum_archive"; then
            log "ERROR" "Falha ao baixar gum com curl"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        if ! wget -q "$gum_url" -O "$gum_archive"; then
            log "ERROR" "Falha ao baixar gum com wget"
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    # Verificar se arquivo foi baixado
    if [[ ! -f "$gum_archive" ]] || [[ ! -s "$gum_archive" ]]; then
        log "ERROR" "Arquivo baixado está vazio ou não existe"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extrair arquivo
    log "INFO" "Extraindo arquivo..."
    if ! tar -xzf "$gum_archive" -C "$temp_dir"; then
        log "ERROR" "Falha ao extrair arquivo"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Encontrar binário do gum
    local gum_binary=$(find "$temp_dir" -name "gum" -type f -executable | head -1)
    if [[ -z "$gum_binary" ]]; then
        log "ERROR" "Binário do gum não encontrado no arquivo extraído"
        ls -la "$temp_dir"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Instalar binário
    log "INFO" "Instalando binário em /usr/local/bin/"
    if sudo mv "$gum_binary" /usr/local/bin/gum; then
        sudo chmod +x /usr/local/bin/gum
        log "SUCCESS" "gum instalado em /usr/local/bin/gum"
    else
        log "ERROR" "Falha ao mover binário para /usr/local/bin/"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Limpeza
    rm -rf "$temp_dir"
    
    # Verificar instalação
    if command -v gum &> /dev/null; then
        log "SUCCESS" "gum instalado com sucesso: $(gum --version)"
        return 0
    else
        log "ERROR" "gum não está disponível após instalação"
        return 1
    fi
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
        install_gum "$os_type" "$arch"
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
