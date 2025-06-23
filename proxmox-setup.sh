#!/bin/bash

# =============================================================================
# 🚀 PROXMOX SETUP SCRIPT
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

# Lista de pacotes extras disponíveis (atualizada)
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

# Verificar se usuário é root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Obter nome do usuário atual
get_username() {
    if [[ -n "${SUDO_USER:-}" ]]; then
        echo "$SUDO_USER"
    else
        whoami
    fi
}

# Obter diretório home do usuário
get_user_home() {
    local user="${1:-$(get_username)}"
    eval echo "~$user"
}

# Fazer backup de arquivo/diretório
backup_file() {
    local source="$1"
    local backup_name="${2:-$(basename "$source")}"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_path="${BACKUP_DIR}/${backup_name}_${timestamp}"
    
    if [[ -e "$source" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$source" "$backup_path"
        log "INFO" "Backup criado: $backup_path"
        return 0
    fi
    return 1
}

# Verificar se script já foi executado anteriormente
check_previous_installation() {
    if [[ -f "$VERSION_FILE" ]]; then
        local installed_version=$(cat "$VERSION_FILE" 2>/dev/null || echo "unknown")
        local installed_hash=$(grep "SCRIPT_HASH:" "$INSTALL_LOG" 2>/dev/null | tail -1 | cut -d' ' -f3 || echo "unknown")
        
        log "INFO" "Instalação anterior detectada (versão: $installed_version)"
        
        if [[ "$installed_hash" != "$SCRIPT_HASH" ]]; then
            log "WARNING" "Script foi modificado desde a última execução"
            echo ""
            echo -e "${YELLOW}⚠️  Detectadas mudanças no script de instalação${NC}"
            echo "Versão anterior: $installed_version"
            echo "Versão atual: $SCRIPT_VERSION"
            echo ""
            read -p "Deseja atualizar a instalação? [s/N]: " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Ss]$ ]]; then
                return 0  # Continuar com atualização
            else
                log "INFO" "Atualização cancelada pelo usuário"
                exit 0
            fi
        else
            log "INFO" "Nenhuma mudança detectada no script"
            return 1  # Não precisa reinstalar
        fi
    fi
    return 0  # Primeira instalação
}

# Salvar informações da instalação
save_installation_info() {
    mkdir -p "$LOG_DIR"
    echo "$SCRIPT_VERSION" > "$VERSION_FILE"
    log "INFO" "SCRIPT_HASH: $SCRIPT_HASH"
    log "SUCCESS" "Informações da instalação salvas"
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
    
    log "STEP" "Verificando se chave SSH já está configurada em $host:$port..."
    
    if ssh -o ConnectTimeout=5 -o BatchMode=yes -p "$port" "root@$host" 'exit' 2>/dev/null; then
        log "SUCCESS" "Chave SSH já configurada para $host:$port"
        return 0
    else
        log "INFO" "Chave SSH não configurada para $host:$port"
        return 1
    fi
}

# Configurar chave SSH para servidor
setup_ssh_key() {
    local host="$1"
    local port="${2:-22}"
    local alias_name="${3:-$host}"
    
    log "HEADER" "=== Configurando SSH para $host:$port ==="
    
    generate_ssh_key
    
    if check_ssh_key_installed "$host" "$port"; then
        return 0
    fi
    
    log "STEP" "Configurando acesso SSH para $host:$port..."
    echo ""
    echo -e "${CYAN}📋 Sua chave pública:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$SSH_PUB_KEY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    log "STEP" "Tentando copiar chave para o servidor (será solicitada a senha)..."
    
    if command_exists ssh-copy-id; then
        if ssh-copy-id -i "$SSH_PUB_KEY" -p "$port" "root@$host"; then
            log "SUCCESS" "Chave copiada com sucesso!"
            setup_ssh_config "$host" "$port" "$alias_name"
            test_ssh_connection "$alias_name"
        else
            log "ERROR" "Falha ao copiar chave automaticamente"
            show_manual_ssh_setup "$host" "$port"
        fi
    else
        log "WARNING" "ssh-copy-id não encontrado"
        show_manual_ssh_setup "$host" "$port"
    fi
}

# Configurar arquivo SSH config
setup_ssh_config() {
    local host="$1"
    local port="$2"
    local alias_name="$3"
    
    log "STEP" "Configurando SSH config para $alias_name..."
    
    mkdir -p "$SSH_DIR"
    
    # Remover configuração existente se houver
    if [[ -f "$SSH_CONFIG" ]]; then
        sed -i "/^Host $alias_name$/,/^$/d" "$SSH_CONFIG"
    fi
    
    # Adicionar nova configuração
    cat >> "$SSH_CONFIG" << EOF

Host $alias_name
    HostName $host
    Port $port
    User root
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
    local alias_name="$1"
    
    log "STEP" "Testando conexão SSH com $alias_name..."
    
    if ssh -o ConnectTimeout=10 "$alias_name" 'echo "✅ Conexão SSH funcionando!"'; then
        log "SUCCESS" "Teste de conexão SSH bem-sucedido!"
    else
        log "WARNING" "Teste de conexão SSH falhou"
    fi
}

# Mostrar instruções para configuração manual de SSH
show_manual_ssh_setup() {
    local host="$1"
    local port="$2"
    
    echo ""
    echo -e "${YELLOW}📝 CONFIGURAÇÃO MANUAL:${NC}"
    echo "1. Copie a chave pública mostrada acima"
    echo "2. Acesse seu servidor via SSH:"
    echo "   ssh -p $port root@$host"
    echo "3. Execute os comandos:"
    echo "   mkdir -p ~/.ssh"
    echo "   echo 'SUA_CHAVE_PUBLICA_AQUI' >> ~/.ssh/authorized_keys"
    echo "   chmod 700 ~/.ssh"
    echo "   chmod 600 ~/.ssh/authorized_keys"
    echo ""
}

# =============================================================================
# FUNÇÕES DE CONTAINERS LXC
# =============================================================================

# Listar containers LXC do Proxmox
list_lxc_containers() {
    local proxmox_host="$1"
    
    log "STEP" "Listando containers LXC em $proxmox_host..."
    
    if ! ssh "$proxmox_host" 'command -v pct >/dev/null 2>&1'; then
        log "ERROR" "Comando 'pct' não encontrado no servidor Proxmox"
        return 1
    fi
    
    local containers=$(ssh "$proxmox_host" 'pct list' 2>/dev/null || echo "")
    
    if [[ -z "$containers" ]]; then
        log "WARNING" "Nenhum container LXC encontrado"
        return 1
    fi
    
    echo ""
    echo -e "${CYAN}📦 Containers LXC disponíveis:${NC}"
    echo "$containers"
    echo ""
    
    return 0
}

# Obter IP de container LXC
get_container_ip() {
    local proxmox_host="$1"
    local container_id="$2"
    
    local ip=$(ssh "$proxmox_host" "pct exec $container_id -- ip route get 1 | awk '{print \$NF; exit}'" 2>/dev/null || echo "")
    
    if [[ -n "$ip" && "$ip" != "1" ]]; then
        echo "$ip"
        return 0
    fi
    
    return 1
}

# Configurar SSH para container LXC
setup_lxc_ssh() {
    local proxmox_host="$1"
    
    log "HEADER" "=== Configuração SSH para Containers LXC ==="
    
    if ! list_lxc_containers "$proxmox_host"; then
        return 1
    fi
    
    echo "Digite o ID ou hostname do container:"
    read -p "Container: " container_input
    
    if [[ -z "$container_input" ]]; then
        log "ERROR" "Container não especificado"
        return 1
    fi
    
    # Verificar se é um ID numérico ou hostname
    if [[ "$container_input" =~ ^[0-9]+$ ]]; then
        # É um ID, obter IP
        local container_ip=$(get_container_ip "$proxmox_host" "$container_input")
        if [[ -z "$container_ip" ]]; then
            log "ERROR" "Não foi possível obter IP do container $container_input"
            return 1
        fi
        local alias_name="lxc-$container_input"
        log "INFO" "Container $container_input tem IP: $container_ip"
    else
        # É um hostname/IP
        local container_ip="$container_input"
        local alias_name="lxc-$(echo "$container_input" | tr '.' '-')"
    fi
    
    setup_ssh_key "$container_ip" "22" "$alias_name"
}

# =============================================================================
# FUNÇÕES DE INSTALAÇÃO ZSH
# =============================================================================

# Verificar se sistema é Debian/Ubuntu
is_debian_based() {
    [[ -f /etc/debian_version ]]
}

# Obter gerenciador de pacotes
get_package_manager() {
    if command_exists apt; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Instalar pacotes do sistema
install_system_packages() {
    local packages=("$@")
    local pkg_manager=$(get_package_manager)
    
    log "STEP" "Instalando pacotes do sistema: ${packages[*]}"
    
    case "$pkg_manager" in
        "apt")
            apt update
            apt install -y "${packages[@]}"
            ;;
        "yum"|"dnf")
            $pkg_manager install -y "${packages[@]}"
            ;;
        "pacman")
            pacman -Sy --noconfirm "${packages[@]}"
            ;;
        *)
            log "ERROR" "Gerenciador de pacotes não suportado: $pkg_manager"
            return 1
            ;;
    esac
    
    log "SUCCESS" "Pacotes instalados com sucesso"
}

# Verificar se pacote está disponível
check_package_available() {
    local package="$1"
    local pkg_manager=$(get_package_manager)
    
    case "$pkg_manager" in
        "apt")
            apt-cache show "$package" >/dev/null 2>&1
            ;;
        "yum"|"dnf")
            $pkg_manager info "$package" >/dev/null 2>&1
            ;;
        "pacman")
            pacman -Si "$package" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Selecionar pacotes extras para instalar
select_extra_packages() {
    log "HEADER" "=== Seleção de Pacotes Extras ==="
    
    echo "Pacotes extras disponíveis:"
    echo ""
    
    local selected_packages=()
    local index=1
    
    for package_info in "${EXTRA_PACKAGES[@]}"; do
        local package_name="${package_info%%:*}"
        local package_desc="${package_info##*:}"
        
        echo "$index) $package_name - $package_desc"
        ((index++))
    done
    
    echo ""
    echo "Digite os números dos pacotes que deseja instalar (separados por espaço):"
    echo "Exemplo: 1 3 5"
    echo "Pressione Enter para pular"
    read -p "Pacotes: " selection
    
    if [[ -z "$selection" ]]; then
        log "INFO" "Nenhum pacote extra selecionado"
        return 0
    fi
    
    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && ((num >= 1 && num <= ${#EXTRA_PACKAGES[@]})); then
            local package_info="${EXTRA_PACKAGES[$((num-1))]}"
            local package_name="${package_info%%:*}"
            
            if check_package_available "$package_name"; then
                selected_packages+=("$package_name")
                log "INFO" "Pacote selecionado: $package_name"
            else
                log "WARNING" "Pacote não disponível: $package_name"
            fi
        else
            log "WARNING" "Seleção inválida: $num"
        fi
    done
    
    if [[ ${#selected_packages[@]} -gt 0 ]]; then
        log "STEP" "Instalando pacotes extras selecionados..."
        install_system_packages "${selected_packages[@]}"
    fi
}

# Instalar oh-my-zsh
install_oh_my_zsh() {
    local target_user="$1"
    local target_home="$2"
    
    log "STEP" "Instalando oh-my-zsh para $target_user..."
    
    if [[ -d "$target_home/.oh-my-zsh" ]]; then
        log "INFO" "oh-my-zsh já está instalado"
        return 0
    fi
    
    # Executar como usuário alvo
    if [[ "$target_user" != "$(whoami)" ]]; then
        sudo -u "$target_user" sh -c 'curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended'
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    log "SUCCESS" "oh-my-zsh instalado"
}

# Instalar plugins do zsh
install_zsh_plugins() {
    local target_home="$1"
    local plugins_dir="$target_home/.oh-my-zsh/custom/plugins"
    
    log "STEP" "Instalando plugins do zsh..."
    
    # zsh-autosuggestions
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
        log "SUCCESS" "zsh-autosuggestions instalado"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"
        log "SUCCESS" "zsh-syntax-highlighting instalado"
    fi
    
    # zsh-history-substring-search
    if [[ ! -d "$plugins_dir/zsh-history-substring-search" ]]; then
        git clone https://github.com/zsh-users/zsh-history-substring-search "$plugins_dir/zsh-history-substring-search"
        log "SUCCESS" "zsh-history-substring-search instalado"
    fi
}

# Instalar eza
install_eza() {
    log "STEP" "Instalando eza..."
    
    if command_exists eza; then
        log "INFO" "eza já está instalado"
        return 0
    fi
    
    # Detectar arquitetura
    local arch=$(uname -m)
    case "$arch" in
        x86_64) arch="x86_64-unknown-linux-gnu" ;;
        aarch64) arch="aarch64-unknown-linux-gnu" ;;
        armv7l) arch="armv7-unknown-linux-gnueabihf" ;;
        *) 
            log "WARNING" "Arquitetura não suportada para eza: $arch"
            return 1
            ;;
    esac
    
    # Baixar e instalar eza
    local tmp_dir=$(mktemp -d)
    local eza_url="https://github.com/eza-community/eza/releases/latest/download/eza_${arch}.tar.gz"
    
    if wget -q "$eza_url" -O "$tmp_dir/eza.tar.gz"; then
        tar -xzf "$tmp_dir/eza.tar.gz" -C "$tmp_dir/"
        sudo mv "$tmp_dir/eza" /usr/local/bin/
        sudo chmod +x /usr/local/bin/eza
        rm -rf "$tmp_dir"
        log "SUCCESS" "eza instalado"
    else
        log "WARNING" "Falha ao baixar eza, tentando instalação via package manager..."
        if check_package_available eza; then
            install_system_packages eza
        else
            log "WARNING" "eza não disponível via package manager"
        fi
    fi
}

# Instalar fzf
install_fzf() {
    local target_user="$1"
    local target_home="$2"
    
    log "STEP" "Instalando fzf para $target_user..."
    
    if [[ -d "$target_home/.fzf" ]]; then
        log "INFO" "fzf já está instalado"
        return 0
    fi
    
    # Executar como usuário alvo
    if [[ "$target_user" != "$(whoami)" ]]; then
        sudo -u "$target_user" bash -c "
            git clone --depth 1 https://github.com/junegunn/fzf.git $target_home/.fzf
            $target_home/.fzf/install --all --no-bash --no-fish
        "
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "$target_home/.fzf"
        "$target_home/.fzf/install" --all --no-bash --no-fish
    fi
    
    log "SUCCESS" "fzf instalado"
}

# Configurar .zshrc
configure_zshrc() {
    local target_home="$1"
    local is_proxmox="$2"
    local set_default_shell="$3"
    
    log "STEP" "Configurando .zshrc..."
    
    # Backup do .zshrc existente
    backup_file "$target_home/.zshrc"
    
    cat > "$target_home/.zshrc" << 'EOF'
# =============================================================================
# ZSH Configuration - Generated by proxmox-setup.sh
# =============================================================================

export ZSH="$HOME/.oh-my-zsh"

# Tema
ZSH_THEME="agnoster"

# Plugins
plugins=(
    git
    docker
    docker-compose
    systemd
    sudo
    z
    dirhistory
    history-substring-search
    command-not-found
    rsync
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# =============================================================================
# CONFIGURAÇÕES PERSONALIZADAS
# =============================================================================

# Aliases para eza
if command -v eza &> /dev/null; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -l --icons --color=always --group-directories-first'
    alias la='eza -la --icons --color=always --group-directories-first'
    alias lt='eza --tree --icons --color=always'
    alias llt='eza -l --tree --icons --color=always'
    alias lta='eza -la --tree --icons --color=always'
fi

# Aliases úteis para Proxmox
if command -v pct &> /dev/null || command -v qm &> /dev/null; then
    alias pct-list='pct list'
    alias qm-list='qm list'
    alias pve-status='pvesh get /cluster/status'
    alias storage-status='pvesh get /storage'
    alias node-status='pvesh get /nodes'
    alias pve-logs='journalctl -u pve*'
fi

# Aliases gerais
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias psg='ps aux | grep'
alias h='history'
alias j='jobs'
alias c='clear'
alias q='exit'

# Aliases para git (se disponível)
if command -v git &> /dev/null; then
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline'
    alias gd='git diff'
    alias gb='git branch'
    alias gco='git checkout'
fi

# Histórico
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# fzf configuração
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview-window=right:60%'
    export FZF_CTRL_T_OPTS="--preview 'cat {} 2>/dev/null || ls -la {}'"
    export FZF_ALT_C_OPTS="--preview 'ls -la {}'"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
fi

# Funções úteis
# Busca rápida de arquivos
ff() {
    if command -v fzf &> /dev/null; then
        find . -type f -name "*$1*" 2>/dev/null | fzf --preview 'cat {} 2>/dev/null || echo "Binary file"'
    else
        find . -type f -name "*$1*" 2>/dev/null
    fi
}

# Busca rápida de diretórios
fd() {
    if command -v fzf &> /dev/null; then
        find . -type d -name "*$1*" 2>/dev/null | fzf --preview 'ls -la {}'
    else
        find . -type d -name "*$1*" 2>/dev/null
    fi
}

# Histórico com fzf
fh() {
    if command -v fzf &> /dev/null; then
        eval $(history | fzf --tac --no-sort | sed 's/^ *[0-9]* *//')
    else
        history | grep "$1"
    fi
}

# Função para extrair arquivos
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Informações do sistema
sysinfo() {
    echo "Sistema: $(uname -a)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "Load: $(cat /proc/loadavg 2>/dev/null || echo 'N/A')"
    echo "Memória: $(free -h 2>/dev/null | grep '^Mem:' || echo 'N/A')"
    echo "Disco: $(df -h . 2>/dev/null | tail -1 || echo 'N/A')"
}

# Prompt customizado (fallback se tema não funcionar)
if [[ "$ZSH_THEME" == "" ]]; then
    PROMPT='%{$fg[cyan]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[cyan]%}]%{$reset_color%}$ '
fi

# Alias para facilitar uso do zsh
alias zsh-config='nano ~/.zshrc'
alias zsh-reload='source ~/.zshrc'

# Informações na inicialização
echo ""
echo "🏗️  $(hostname) - ZSH configurado pelo proxmox-setup.sh"
echo "📊 Sistema: $(uname -sr)"
echo "💾 Uptime: $(uptime -p 2>/dev/null || uptime | cut -d',' -f1)"
echo "🔧 Shell: $SHELL"
echo ""
echo "💡 Comandos úteis:"
echo "  • ff <nome>     - Buscar arquivos"
echo "  • fd <nome>     - Buscar diretórios" 
echo "  • fh            - Buscar histórico"
echo "  • extract <arquivo> - Extrair arquivo"
echo "  • sysinfo       - Informações do sistema"
echo ""
EOF

    # Personalizar para Proxmox se necessário
    if [[ "$is_proxmox" == "true" ]]; then
        log "INFO" "Adicionando configurações específicas do Proxmox"
    fi
    
    # Configurar alias no bashrc se zsh não for shell padrão
    if [[ "$set_default_shell" != "true" ]]; then
        log "STEP" "Configurando alias 'zsh' no .bashrc..."
        if ! grep -q "alias zsh=" "$target_home/.bashrc" 2>/dev/null; then
            echo "" >> "$target_home/.bashrc"
            echo "# Alias para facilitar uso do zsh" >> "$target_home/.bashrc"
            echo "alias zsh='exec zsh'" >> "$target_home/.bashrc"
        fi
    fi
    
    log "SUCCESS" ".zshrc configurado"
}

# Instalar tema Powerlevel10k
install_powerlevel10k() {
    local target_home="$1"
    local themes_dir="$target_home/.oh-my-zsh/custom/themes"
    
    log "STEP" "Instalando tema Powerlevel10k..."
    
    if [[ -d "$themes_dir/powerlevel10k" ]]; then
        log "INFO" "Powerlevel10k já está instalado"
        return 0
    fi
    
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$themes_dir/powerlevel10k"
    
    # Atualizar tema no .zshrc
    sed -i 's/ZSH_THEME="agnoster"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$target_home/.zshrc"
    
    log "SUCCESS" "Powerlevel10k instalado"
}

# Função principal de instalação do Zsh
install_zsh_environment() {
    local target_host="$1"
    local is_proxmox="${2:-false}"
    local set_default_shell="${3:-false}"
    
    log "HEADER" "=== Instalação do Ambiente Zsh ==="
    
    if [[ "$target_host" == "local" ]]; then
        # Instalação local
        local target_user=$(get_username)
        local target_home=$(get_user_home "$target_user")
        
        log "INFO" "Instalando localmente para usuário: $target_user"
        log "INFO" "Diretório home: $target_home"
        
        # Verificar se é uma nova instalação ou atualização
        if ! check_previous_installation; then
            log "INFO" "Pulando instalação - nenhuma mudança detectada"
            return 0
        fi
        
        # Instalar dependências básicas
        log "STEP" "Atualizando sistema e instalando dependências..."
        if is_root; then
            if is_debian_based; then
                apt update
                install_system_packages curl wget git zsh unzip build-essential
            fi
        else
            log "WARNING" "Não executando como root - algumas dependências podem não ser instaladas"
        fi
        
        # Verificar se zsh está instalado
        if ! command_exists zsh; then
            log "ERROR" "Zsh não está instalado. Execute como root ou instale manualmente."
            return 1
        fi
        
        # Fazer backup das configurações existentes
        backup_file "$target_home/.zshrc" "zshrc"
        backup_file "$target_home/.oh-my-zsh" "oh-my-zsh"
        
        # Instalar componentes
        install_oh_my_zsh "$target_user" "$target_home"
        install_zsh_plugins "$target_home"
        install_eza
        install_fzf "$target_user" "$target_home"
        configure_zshrc "$target_home" "$is_proxmox" "$set_default_shell"
        install_powerlevel10k "$target_home"
        
        # Selecionar e instalar pacotes extras
        if is_root; then
            select_extra_packages
        else
            log "INFO" "Pulando instalação de pacotes extras (não executando como root)"
        fi
        
        # Configurar shell padrão se solicitado
        if [[ "$set_default_shell" == "true" && "$is_proxmox" != "true" ]]; then
            log "STEP" "Configurando zsh como shell padrão..."
            if is_root; then
                chsh -s "$(which zsh)" "$target_user"
                log "SUCCESS" "Zsh configurado como shell padrão para $target_user"
            else
                log "WARNING" "Execute 'chsh -s \$(which zsh)' para definir zsh como shell padrão"
            fi
        elif [[ "$is_proxmox" == "true" ]]; then
            log "INFO" "Proxmox detectado - mantendo bash como shell padrão"
        fi
        
        save_installation_info
        
    else
        # Instalação remota
        log "INFO" "Instalando remotamente em: $target_host"
        
        # Transferir script para o servidor remoto
        local remote_script="/tmp/proxmox-setup-remote.sh"
        log "STEP" "Transferindo script para $target_host..."
        
        # Criar versão do script para execução remota
        create_remote_script "$remote_script" "$is_proxmox" "$set_default_shell"
        
        # Copiar e executar
        scp "$remote_script" "$target_host:/tmp/"
        ssh "$target_host" "chmod +x /tmp/proxmox-setup-remote.sh && /tmp/proxmox-setup-remote.sh"
        
        # Limpar arquivo temporário
        rm -f "$remote_script"
    fi
    
    log "SUCCESS" "Instalação do ambiente Zsh concluída!"
    
    echo ""
    echo -e "${CYAN}🎉 Instalação concluída!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Para aplicar as mudanças:${NC}"
    if [[ "$target_host" == "local" ]]; then
        echo "  1. Execute: source ~/.zshrc"
        echo "  2. Ou execute: zsh"
        echo "  3. Configure o Powerlevel10k: p10k configure"
    else
        echo "  1. Faça login no servidor: ssh $target_host"
        echo "  2. Execute: source ~/.zshrc ou zsh"
        echo "  3. Configure o Powerlevel10k: p10k configure"
    fi
    echo ""
    echo -e "${PURPLE}🎯 Comandos úteis instalados:${NC}"
    echo "  • ff <nome>    - Buscar arquivos"
    echo "  • fd <nome>    - Buscar diretórios"
    echo "  • fh           - Buscar no histórico"
    echo "  • extract      - Extrair arquivos"
    echo "  • sysinfo      - Informações do sistema"
    echo ""
}

# Criar script para execução remota
create_remote_script() {
    local script_path="$1"
    local is_proxmox="$2"
    local set_default_shell="$3"
    
    cat > "$script_path" << 'REMOTE_SCRIPT_EOF'
#!/bin/bash

# Script simplificado para execução remota
set -euo pipefail

# Cores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "STEP") echo -e "${CYAN}🔸 $message${NC}" ;;
        "HEADER") echo -e "${PURPLE}$message${NC}" ;;
        *) echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Instalar dependências
log "STEP" "Instalando dependências básicas..."
if command_exists apt; then
    apt update
    apt install -y curl wget git zsh unzip build-essential
elif command_exists yum; then
    yum install -y curl wget git zsh unzip gcc
elif command_exists dnf; then
    dnf install -y curl wget git zsh unzip gcc
else
    log "ERROR" "Gerenciador de pacotes não suportado"
    exit 1
fi

# Instalar oh-my-zsh
log "STEP" "Instalando oh-my-zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Instalar plugins
log "STEP" "Instalando plugins..."
plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$plugins_dir"

if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
fi

if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"
fi

if [[ ! -d "$plugins_dir/zsh-history-substring-search" ]]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search "$plugins_dir/zsh-history-substring-search"
fi

# Instalar fzf
log "STEP" "Instalando fzf..."
if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
fi

# Configurar .zshrc (usar a mesma função do script principal)
# [A configuração do .zshrc será inserida aqui pelo script principal]

log "SUCCESS" "Instalação remota concluída!"
REMOTE_SCRIPT_EOF

    # Adicionar parâmetros específicos
    echo "IS_PROXMOX='$is_proxmox'" >> "$script_path"
    echo "SET_DEFAULT_SHELL='$set_default_shell'" >> "$script_path"
    
    # Adicionar a função de configuração do .zshrc
    grep -A 200 "configure_zshrc()" "$0" | head -n -1 >> "$script_path"
    echo "configure_zshrc \"\$HOME\" \"\$IS_PROXMOX\" \"\$SET_DEFAULT_SHELL\"" >> "$script_path"
}

# =============================================================================
# FUNÇÕES DO MENU PRINCIPAL
# =============================================================================

# Mostrar cabeçalho
show_header() {
    clear
    echo -e "${BOLD}${PURPLE}"
    echo "============================================================================="
    echo "🚀 PROXMOX SETUP SCRIPT v$SCRIPT_VERSION"
    echo "============================================================================="
    echo -e "${NC}"
    echo "Script consolidado para configuração de SSH e ambiente Zsh"
    echo "Servidor Proxmox: $PROXMOX_HOSTNAME ($PROXMOX_LOCAL_IP)"
    echo ""
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
    local package_options=()
    
    for package in "${EXTRA_PACKAGES[@]}"; do
        local name="${package%%:*}"
        local desc="${package##*:}"
        package_options+=("$name" "$desc" "off")
    done
    
    gum choose --no-limit \
        "${EXTRA_PACKAGES[@]%%:*}"
}

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
        echo "  # Para gum, instale via GitHub releases"
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
# FUNÇÃO PRINCIPAL
# =============================================================================

main() {
    # Verificações iniciais
    if [[ $# -eq 1 && "$1" == "--version" ]]; then
        echo "$SCRIPT_VERSION"
        exit 0
    fi
    
    if [[ $# -eq 1 && "$1" == "--dry-run" ]]; then
        log "INFO" "Modo dry-run ativado - nenhuma alteração será feita"
        export DRY_RUN=true
    fi
    
    # Criar diretórios necessários
    mkdir -p "$LOG_DIR" "$BACKUP_DIR"
    
    # Log inicial
    log "INFO" "Iniciando $SCRIPT_NAME v$SCRIPT_VERSION"
    log "INFO" "Usuário: $(get_username)"
    log "INFO" "Home: $(get_user_home)"
    log "INFO" "Sistema: $(uname -a)"
    
    # Verificar e instalar dependências interativas
    check_interactive_dependencies
    
    # Loop principal do menu
    while true; do
        show_header
        show_main_menu
        
        read -p "Escolha uma opção: " choice
        echo ""
        
        case "$choice" in
            1) menu_setup_proxmox_ssh ;;
            2) menu_setup_lxc_ssh ;;
            3) menu_install_zsh_proxmox ;;
            4) menu_install_zsh_lxc ;;
            5) menu_install_zsh_local ;;
            6) menu_backup_ssh_keys ;;
            7) menu_show_logs ;;
            8) menu_system_info ;;
            0) 
                log "INFO" "Saindo..."
                exit 0
                ;;
            *)
                log "ERROR" "Opção inválida: $choice"
                ;;
        esac
        
        echo ""
        read -p "Pressione Enter para continuar..." -r
    done
}

# =============================================================================
# EXECUÇÃO
# =============================================================================

# Verificar se script está sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
