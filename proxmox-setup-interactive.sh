#!/bin/bash

# =============================================================================
# 🚀 PROXMOX SETUP SCRIPT (INTERACTIVE VERSION)
# =============================================================================
# Script consolidado para configuração de SSH e ambiente Zsh 
# tanto para servidor Proxmox quanto para containers LXC
# Utiliza gum e fzf para interface interativa
#
# Autor: Marcus
# Data: $(date '+%Y-%m-%d')
# Versão: 2.0.0
# =============================================================================

set -euo pipefail  # Strict mode

# =============================================================================
# CONFIGURAÇÕES GLOBAIS
# =============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_HASH=$(sha256sum "$0" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

# Configurações do Proxmox
readonly PROXMOX_HOSTNAME="moria"
readonly PROXMOX_LOCAL_IP="10.11.18.100"
readonly PROXMOX_EXTERNAL_IP="77.166.75.30"
readonly PROXMOX_LOCAL_PORT="22"
readonly PROXMOX_EXTERNAL_PORT="2223"

# Diretórios
readonly HOME_DIR="${HOME}"
readonly SSH_DIR="${HOME_DIR}/.ssh"
readonly LOG_DIR="${HOME_DIR}/.proxmox-setup"
readonly BACKUP_DIR="${LOG_DIR}/backups"

# Arquivos
readonly SSH_KEY="${SSH_DIR}/proxmox_key"
readonly SSH_PUB_KEY="${SSH_KEY}.pub"
readonly SSH_CONFIG="${SSH_DIR}/config"
readonly INSTALL_LOG="${LOG_DIR}/install.log"
readonly VERSION_FILE="${LOG_DIR}/version"

# Cores para output (compatibilidade com gum)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Lista de pacotes extras disponíveis
readonly EXTRA_PACKAGES=(
    "nfs-utils:Cliente NFS para montagem de compartilhamentos"
    "cifs-utils:Cliente CIFS/SMB para Windows shares"
    "bat:Cat melhorado com syntax highlighting"
    "htop:Monitor de processos interativo"
    "ncdu:Analisador de uso de disco"
    "tree:Visualizador de estrutura de diretórios"
    "tmux:Multiplexador de terminal"
    "vim:Editor de texto avançado"
    "nano:Editor de texto simples"
    "rsync:Ferramenta de sincronização"
    "gum:Interface interativa para scripts"
)

# =============================================================================
# FUNÇÕES DE DEPENDÊNCIAS E VERIFICAÇÃO
# =============================================================================

# Verificar se as dependências interativas estão instaladas
check_interactive_dependencies() {
    local deps=("gum" "fzf")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Dependências necessárias não encontradas: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}ℹ️  Este script requer gum e fzf para interface interativa${NC}"
        echo
        echo "Instalação das dependências:"
        echo "• gum: https://github.com/charmbracelet/gum"
        echo "• fzf: https://github.com/junegunn/fzf"
        echo
        echo "Ubuntu/Debian:"
        echo "  sudo apt install fzf"
        echo "  # Para gum, baixe do GitHub releases"
        echo
        
        read -p "Tentar instalar automaticamente? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_interactive_deps
        else
            exit 1
        fi
    fi
}

# Instalar dependências interativas
install_interactive_deps() {
    echo -e "${CYAN}🔸 Instalando dependências interativas...${NC}"
    
    # Instalar fzf se não estiver disponível
    if ! command -v fzf &> /dev/null; then
        echo -e "${BLUE}ℹ️  Instalando fzf...${NC}"
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y fzf
        elif command -v yum &> /dev/null; then
            sudo yum install -y fzf
        elif command -v pacman &> /dev/null; then
            sudo pacman -S fzf
        else
            # Instalação manual
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all
        fi
    fi
    
    # Instalar gum se não estiver disponível
    if ! command -v gum &> /dev/null; then
        echo -e "${BLUE}ℹ️  Instalando gum...${NC}"
        # Detectar arquitetura
        local arch
        case "$(uname -m)" in
            x86_64) arch="x86_64" ;;
            aarch64|arm64) arch="arm64" ;;
            armv7l) arch="armv6" ;;
            *) arch="x86_64" ;;
        esac
        
        # Baixar e instalar gum
        local gum_url="https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_${arch}.tar.gz"
        wget -q "$gum_url" -O /tmp/gum.tar.gz
        tar -xzf /tmp/gum.tar.gz -C /tmp/
        sudo mv /tmp/gum /usr/local/bin/
        sudo chmod +x /usr/local/bin/gum
        rm -f /tmp/gum.tar.gz
    fi
    
    echo -e "${GREEN}✅ Dependências interativas instaladas!${NC}"
}

# =============================================================================
# FUNÇÕES DE INTERFACE INTERATIVA
# =============================================================================

# Mostrar header do script
show_header() {
    clear
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 80 --margin "1 2" --padding "2 4" \
        '🚀 PROXMOX SETUP SCRIPT' \
        '' \
        'Configuração automatizada de SSH e ambiente Zsh' \
        'Servidor Proxmox e Containers LXC' \
        '' \
        "Versão: $SCRIPT_VERSION"
}

# Menu principal interativo
show_main_menu() {
    gum choose \
        "🔐 Configurar SSH para Proxmox" \
        "🔐 Configurar SSH para Container LXC" \
        "🐚 Instalar Zsh no Proxmox (remoto)" \
        "🐚 Instalar Zsh em Container LXC (remoto)" \
        "🐚 Instalar Zsh localmente" \
        "📦 Gerenciar pacotes extras" \
        "🔧 Backup de chaves SSH" \
        "📊 Visualizar logs de instalação" \
        "ℹ️  Informações do sistema" \
        "❌ Sair"
}

# Selecionar método de conexão
select_connection_method() {
    local target_name="$1"
    
    gum style --foreground 33 "🌐 Selecione o método de conexão para $target_name:"
    echo
    
    gum choose \
        "🏠 Rede Local (${PROXMOX_LOCAL_IP}:${PROXMOX_LOCAL_PORT})" \
        "🌍 Rede Externa (${PROXMOX_EXTERNAL_IP}:${PROXMOX_EXTERNAL_PORT})" \
        "🔧 IP Customizado"
}

# Selecionar containers LXC
select_lxc_container() {
    local containers
    
    gum style --foreground 33 "🔍 Buscando containers LXC no Proxmox..."
    echo
    
    # Tentar obter lista de containers via SSH
    if ssh_test_connection "$PROXMOX_HOSTNAME"; then
        containers=$(ssh "$PROXMOX_HOSTNAME" "pct list" 2>/dev/null | tail -n +2 | awk '{print $1":"$3}' || echo "")
        
        if [[ -n "$containers" ]]; then
            echo "$containers" | fzf \
                --prompt="🐳 Selecione um container: " \
                --height=15 \
                --layout=reverse \
                --border \
                --preview='echo "Container ID: {1}" | sed "s/:.*//"; echo "Status: {2}" | sed "s/.*://"' \
                --preview-window=right:30%
        else
            gum input --placeholder "Digite o ID do container (ex: 101)"
        fi
    else
        gum style --foreground 196 "❌ Não foi possível conectar ao Proxmox"
        gum input --placeholder "Digite o ID do container manualmente (ex: 101)"
    fi
}

# Selecionar pacotes extras
select_extra_packages() {
    gum style --foreground 33 "📦 Selecione os pacotes extras para instalar:"
    echo
    
    # Criar array com apenas os nomes dos pacotes para gum
    local package_names=()
    for package in "${EXTRA_PACKAGES[@]}"; do
        package_names+=("${package%%:*}")
    done
    
    # Usar gum para seleção múltipla
    gum choose --no-limit "${package_names[@]}"
}

# =============================================================================
# FUNÇÕES DE UTILIDADE
# =============================================================================

# Função para logging
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p "$LOG_DIR"
    echo "[$timestamp] [$level] $message" >> "$INSTALL_LOG"
    
    case "$level" in
        "INFO")  echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "STEP") echo -e "${CYAN}🔸 $message${NC}" ;;
        "HEADER") echo -e "${BOLD}${PURPLE}$message${NC}" ;;
    esac
}

# Verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Obter nome do usuário atual
get_username() {
    echo "${USER:-$(whoami)}"
}

# Testar conexão SSH
ssh_test_connection() {
    local host="$1"
    local port="${2:-22}"
    
    ssh -o ConnectTimeout=5 -o BatchMode=yes -p "$port" "$host" exit 2>/dev/null
}

# =============================================================================
# FUNÇÕES DE SSH
# =============================================================================

# Gerar chave SSH se não existir
generate_ssh_key() {
    if [[ ! -f "$SSH_PUB_KEY" ]]; then
        log "STEP" "Gerando nova chave SSH..."
        mkdir -p "$SSH_DIR"
        ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "$(get_username)@$(hostname)-proxmox"
        chmod 700 "$SSH_DIR"
        chmod 600 "$SSH_KEY"
        chmod 644 "$SSH_PUB_KEY"
        log "SUCCESS" "Chave SSH gerada: $SSH_PUB_KEY"
    else
        log "INFO" "Chave SSH já existe: $SSH_PUB_KEY"
    fi
}

# Verificar se chave SSH já está configurada no servidor
check_ssh_key_installed() {
    local host="$1"
    local port="${2:-22}"
    
    log "STEP" "Verificando se chave SSH já está configurada..."
    
    if ssh_test_connection "$host" "$port"; then
        log "SUCCESS" "Chave SSH já está configurada e funcionando!"
        return 0
    else
        log "INFO" "Chave SSH não está configurada ou não está funcionando"
        return 1
    fi
}

# Copiar chave SSH para servidor
copy_ssh_key_to_server() {
    local host="$1"
    local port="$2"
    local user="$3"
    
    log "STEP" "Copiando chave SSH para $user@$host:$port..."
    
    # Mostrar chave pública para o usuário
    gum style --foreground 33 "📋 Sua chave pública:"
    gum style --border normal --padding "1 2" "$(cat "$SSH_PUB_KEY")"
    
    # Tentar ssh-copy-id primeiro
    if command_exists ssh-copy-id; then
        if gum confirm "Usar ssh-copy-id para copiar automaticamente?"; then
            if ssh-copy-id -i "$SSH_PUB_KEY" -p "$port" "$user@$host"; then
                log "SUCCESS" "Chave copiada com sucesso!"
                return 0
            else
                log "WARNING" "ssh-copy-id falhou, use o método manual"
            fi
        fi
    fi
    
    # Instruções manuais
    gum style --foreground 196 "📝 Configuração Manual Necessária:"
    echo
    echo "1. Acesse o servidor: ssh -p $port $user@$host"
    echo "2. Execute os comandos:"
    echo "   mkdir -p ~/.ssh"
    echo "   echo '$(cat "$SSH_PUB_KEY")' >> ~/.ssh/authorized_keys"
    echo "   chmod 700 ~/.ssh"
    echo "   chmod 600 ~/.ssh/authorized_keys"
    echo
    
    gum input --placeholder "Pressione Enter após configurar manualmente..."
}

# Configurar entrada no SSH config
configure_ssh_config_entry() {
    local alias_name="$1"
    local host="$2"
    local port="$3"
    local user="$4"
    
    log "STEP" "Configurando entrada SSH config para $alias_name..."
    
    mkdir -p "$SSH_DIR"
    
    # Backup do config existente
    if [[ -f "$SSH_CONFIG" ]]; then
        cp "$SSH_CONFIG" "${SSH_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Remover configuração existente se houver
    if [[ -f "$SSH_CONFIG" ]] && grep -q "^Host $alias_name$" "$SSH_CONFIG"; then
        sed -i "/^Host $alias_name$/,/^$/d" "$SSH_CONFIG"
    fi
    
    # Adicionar nova configuração
    cat >> "$SSH_CONFIG" << EOF

Host $alias_name
    HostName $host
    Port $port
    User $user
    IdentityFile $SSH_KEY
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
    
    chmod 600 "$SSH_CONFIG"
    log "SUCCESS" "SSH config atualizado para $alias_name"
}

# Testar conexão SSH
test_ssh_connection() {
    local host="$1"
    local port="${2:-22}"
    
    log "STEP" "Testando conexão SSH..."
    
    if ssh -o ConnectTimeout=10 -p "$port" "$host" 'echo "✅ Conexão SSH funcionando!"'; then
        log "SUCCESS" "Teste de conexão SSH bem-sucedido!"
    else
        log "WARNING" "Teste de conexão SSH falhou"
    fi
}

# =============================================================================
# FUNÇÕES DE CONFIGURAÇÃO ESPECÍFICAS
# =============================================================================

# Configurar SSH para Proxmox (versão interativa)
configure_proxmox_ssh() {
    show_header
    gum style --foreground 33 "🔐 Configuração SSH para Proxmox"
    echo
    
    # Selecionar método de conexão
    local connection_method
    connection_method=$(select_connection_method "Proxmox")
    
    local host_ip port
    case "$connection_method" in
        *"Rede Local"*)
            host_ip="$PROXMOX_LOCAL_IP"
            port="$PROXMOX_LOCAL_PORT"
            ;;
        *"Rede Externa"*)
            host_ip="$PROXMOX_EXTERNAL_IP" 
            port="$PROXMOX_EXTERNAL_PORT"
            ;;
        *"IP Customizado"*)
            host_ip=$(gum input --placeholder "Digite o IP do Proxmox")
            port=$(gum input --placeholder "Digite a porta SSH (padrão: 22)" --value "22")
            ;;
    esac
    
    log "INFO" "Configurando SSH para $host_ip:$port"
    
    # Verificar se já existe configuração
    if check_ssh_key_installed "$host_ip" "$port"; then
        gum style --foreground 2 "✅ Chave SSH já está configurada!"
        if gum confirm "Testar conexão SSH?"; then
            test_ssh_connection "$host_ip" "$port"
        fi
        return 0
    fi
    
    # Gerar chave se necessário
    generate_ssh_key
    
    # Copiar chave para servidor
    copy_ssh_key_to_server "$host_ip" "$port" "root"
    
    # Configurar SSH config
    configure_ssh_config_entry "$PROXMOX_HOSTNAME" "$host_ip" "$port" "root"
    
    # Testar conexão
    if gum confirm "Testar conexão SSH?"; then
        test_ssh_connection "$PROXMOX_HOSTNAME"
    fi
    
    gum style --foreground 2 "✅ Configuração SSH para Proxmox concluída!"
    gum input --placeholder "Pressione Enter para continuar..."
}

# Configurar SSH para Container LXC
configure_lxc_ssh() {
    show_header
    gum style --foreground 33 "🔐 Configuração SSH para Container LXC"
    echo
    
    # Selecionar container
    local container_info
    container_info=$(select_lxc_container)
    
    if [[ -z "$container_info" ]]; then
        gum style --foreground 196 "❌ Nenhum container selecionado"
        return 1
    fi
    
    local container_id="${container_info%%:*}"
    local container_ip
    
    # Obter IP do container
    if ssh_test_connection "$PROXMOX_HOSTNAME"; then
        container_ip=$(ssh "$PROXMOX_HOSTNAME" "pct exec $container_id -- ip route get 1.1.1.1 | grep -oP 'src \K\S+'" 2>/dev/null || echo "")
    fi
    
    if [[ -z "$container_ip" ]]; then
        container_ip=$(gum input --placeholder "Digite o IP do container $container_id")
    fi
    
    local container_port
    container_port=$(gum input --placeholder "Digite a porta SSH (padrão: 22)" --value "22")
    
    log "INFO" "Configurando SSH para container $container_id ($container_ip:$container_port)"
    
    # Verificar se já existe configuração
    local container_alias="lxc-$container_id"
    if check_ssh_key_installed "$container_ip" "$container_port"; then
        gum style --foreground 2 "✅ Chave SSH já está configurada!"
        if gum confirm "Testar conexão SSH?"; then
            test_ssh_connection "$container_alias"
        fi
        return 0
    fi
    
    # Gerar chave se necessário
    generate_ssh_key
    
    # Copiar chave para container
    copy_ssh_key_to_server "$container_ip" "$container_port" "root"
    
    # Configurar SSH config
    configure_ssh_config_entry "$container_alias" "$container_ip" "$container_port" "root"
    
    # Testar conexão
    if gum confirm "Testar conexão SSH?"; then
        test_ssh_connection "$container_alias"
    fi
    
    gum style --foreground 2 "✅ Configuração SSH para container concluída!"
    gum input --placeholder "Pressione Enter para continuar..."
}

# Gerenciar pacotes extras
manage_extra_packages() {
    show_header
    gum style --foreground 33 "📦 Gerenciamento de Pacotes Extras"
    echo
    
    local selected_packages
    selected_packages=$(select_extra_packages)
    
    if [[ -z "$selected_packages" ]]; then
        gum style --foreground 33 "ℹ️  Nenhum pacote selecionado"
        gum input --placeholder "Pressione Enter para continuar..."
        return 0
    fi
    
    gum style --foreground 33 "📋 Pacotes selecionados:"
    echo "$selected_packages"
    echo
    
    if gum confirm "Instalar estes pacotes?"; then
        echo "$selected_packages" | while read -r package; do
            [[ -n "$package" ]] && install_package "$package"
        done
        gum style --foreground 2 "✅ Instalação de pacotes concluída!"
    fi
    
    gum input --placeholder "Pressione Enter para continuar..."
}

# Instalar um pacote
install_package() {
    local package="$1"
    
    log "STEP" "Instalando $package..."
    
    if command_exists apt; then
        sudo apt update && sudo apt install -y "$package"
    elif command_exists yum; then
        sudo yum install -y "$package"
    elif command_exists pacman; then
        sudo pacman -S "$package"
    else
        log "ERROR" "Gerenciador de pacotes não suportado"
        return 1
    fi
    
    log "SUCCESS" "$package instalado"
}

# Visualizar logs
view_logs() {
    show_header
    gum style --foreground 33 "📊 Logs de Instalação"
    echo
    
    if [[ -f "$INSTALL_LOG" ]]; then
        gum pager < "$INSTALL_LOG"
    else
        gum style --foreground 196 "❌ Arquivo de log não encontrado"
    fi
    
    gum input --placeholder "Pressione Enter para continuar..."
}

# Mostrar informações do sistema
show_system_info() {
    show_header
    gum style --foreground 33 "ℹ️  Informações do Sistema"
    echo
    
    {
        echo "🖥️  Sistema Operacional: $(uname -o)"
        echo "🏗️  Arquitetura: $(uname -m)"
        echo "🐧 Kernel: $(uname -r)"
        echo "👤 Usuário: $(get_username)"
        echo "🏠 Home: $HOME_DIR"
        echo "📂 Log Directory: $LOG_DIR"
        echo "🔑 SSH Key: $SSH_KEY"
        echo "📝 Script Version: $SCRIPT_VERSION"
        echo
        echo "🔧 Dependências:"
        if command_exists gum; then
            echo "  ✅ gum: $(gum --version 2>/dev/null || echo "instalado")"
        else
            echo "  ❌ gum: não instalado"
        fi
        if command_exists fzf; then
            echo "  ✅ fzf: $(fzf --version 2>/dev/null | cut -d' ' -f1 || echo "instalado")"
        else
            echo "  ❌ fzf: não instalado"
        fi
    } | gum style --border normal --padding "1 2"
    
    gum input --placeholder "Pressione Enter para continuar..."
}

# Backup de chaves SSH
backup_ssh_keys() {
    show_header
    gum style --foreground 33 "🔧 Backup de Chaves SSH"
    echo
    
    local backup_name="ssh-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log "STEP" "Criando backup das chaves SSH..."
    
    mkdir -p "$BACKUP_DIR"
    
    if [[ -d "$SSH_DIR" ]]; then
        tar -czf "$backup_path" -C "$HOME_DIR" .ssh/
        log "SUCCESS" "Backup criado: $backup_path"
        gum style --foreground 2 "✅ Backup de chaves SSH criado com sucesso!"
        gum style --border normal "📁 Local: $backup_path"
    else
        log "ERROR" "Diretório SSH não encontrado"
        gum style --foreground 196 "❌ Diretório SSH não encontrado"
    fi
    
    gum input --placeholder "Pressione Enter para continuar..."
}

# =============================================================================
# FUNÇÃO PRINCIPAL E LOOP DO MENU
# =============================================================================

# Loop principal do menu
main_menu() {
    while true; do
        show_header
        
        local choice
        choice=$(show_main_menu)
        
        case "$choice" in
            *"SSH para Proxmox"*)
                configure_proxmox_ssh
                ;;
            *"SSH para Container LXC"*)
                configure_lxc_ssh
                ;;
            *"Zsh no Proxmox"*)
                gum style --foreground 33 "🚧 Funcionalidade em desenvolvimento"
                gum input --placeholder "Pressione Enter para continuar..."
                ;;
            *"Zsh em Container LXC"*)
                gum style --foreground 33 "🚧 Funcionalidade em desenvolvimento"
                gum input --placeholder "Pressione Enter para continuar..."
                ;;
            *"Zsh localmente"*)
                gum style --foreground 33 "🚧 Funcionalidade em desenvolvimento"
                gum input --placeholder "Pressione Enter para continuar..."
                ;;
            *"pacotes extras"*)
                manage_extra_packages
                ;;
            *"Backup"*)
                backup_ssh_keys
                ;;
            *"logs"*)
                view_logs
                ;;
            *"Informações"*)
                show_system_info
                ;;
            *"Sair"*)
                gum style --foreground 2 "👋 Obrigado por usar o Proxmox Setup Script!"
                exit 0
                ;;
        esac
    done
}

# =============================================================================
# ENTRADA DO SCRIPT
# =============================================================================

# Função principal
main() {
    # Verificar argumentos da linha de comando
    case "${1:-}" in
        "--version")
            echo "$SCRIPT_NAME v$SCRIPT_VERSION"
            exit 0
            ;;
        "--dry-run")
            echo "🧪 Modo dry-run - nenhuma alteração será feita"
            export DRY_RUN=true
            ;;
        "--help"|"-h")
            echo "Uso: $SCRIPT_NAME [--version|--dry-run|--help]"
            echo
            echo "Opções:"
            echo "  --version    Mostrar versão"
            echo "  --dry-run    Modo simulação"
            echo "  --help       Mostrar esta ajuda"
            exit 0
            ;;
    esac
    
    # Verificar dependências
    check_interactive_dependencies
    
    # Configurar diretórios
    mkdir -p "$LOG_DIR" "$BACKUP_DIR"
    
    # Log inicial
    log "INFO" "=== Iniciando Proxmox Setup Script v$SCRIPT_VERSION ==="
    log "INFO" "Usuário: $(get_username)"
    log "INFO" "Diretório: $SCRIPT_DIR"
    log "INFO" "Hash do script: $SCRIPT_HASH"
    
    # Iniciar menu principal
    main_menu
}

# Executar função principal se script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
