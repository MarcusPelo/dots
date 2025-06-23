#!/bin/bash

# =============================================================================
# 🧪 SCRIPT DE TESTE - PROXMOX SETUP
# =============================================================================
# Este script demonstra o uso do proxmox-setup.sh em modo dry-run
# para verificar a funcionalidade sem fazer alterações reais
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MAIN_SCRIPT="$SCRIPT_DIR/proxmox-setup.sh"

# Cores
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

print_header() {
    echo -e "${PURPLE}"
    echo "============================================================================="
    echo "🧪 TESTE DO PROXMOX SETUP SCRIPT"
    echo "============================================================================="
    echo -e "${NC}"
    echo "Este script irá demonstrar as funcionalidades do proxmox-setup.sh"
    echo "em modo dry-run (simulação) para verificar o funcionamento."
    echo ""
}

print_step() {
    echo -e "${CYAN}🔸 $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Verificar se o script principal existe
check_main_script() {
    print_step "Verificando script principal..."
    
    if [[ ! -f "$MAIN_SCRIPT" ]]; then
        echo "❌ Script principal não encontrado: $MAIN_SCRIPT"
        exit 1
    fi
    
    if [[ ! -x "$MAIN_SCRIPT" ]]; then
        echo "❌ Script principal não é executável: $MAIN_SCRIPT"
        echo "Execute: chmod +x $MAIN_SCRIPT"
        exit 1
    fi
    
    print_success "Script principal encontrado e executável"
}

# Verificar versão
check_version() {
    print_step "Verificando versão do script..."
    
    local version=$("$MAIN_SCRIPT" --version 2>/dev/null || echo "unknown")
    print_info "Versão detectada: $version"
}

# Verificar dependências básicas
check_dependencies() {
    print_step "Verificando dependências básicas..."
    
    local deps=("bash" "ssh" "git" "curl" "wget")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            print_info "$dep: ✅ disponível"
        else
            print_warning "$dep: ❌ não encontrado"
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "Dependências faltando: ${missing_deps[*]}"
        print_info "Algumas funcionalidades podem não funcionar corretamente"
    else
        print_success "Todas as dependências básicas estão disponíveis"
    fi
}

# Simular estrutura de arquivos
simulate_file_structure() {
    print_step "Simulando estrutura de arquivos que será criada..."
    
    local home_dir="${HOME}"
    local ssh_dir="${home_dir}/.ssh"
    local log_dir="${home_dir}/.proxmox-setup"
    
    echo ""
    echo "📂 Estrutura de diretórios:"
    echo "   $ssh_dir/"
    echo "   ├── proxmox_key           # Chave privada SSH"
    echo "   ├── proxmox_key.pub       # Chave pública SSH"
    echo "   └── config                # Configuração SSH"
    echo ""
    echo "   $log_dir/"
    echo "   ├── install.log           # Log das operações"
    echo "   ├── version               # Versão da instalação"
    echo "   └── backups/              # Backups automáticos"
    echo "       ├── zshrc_TIMESTAMP"
    echo "       ├── oh-my-zsh_TIMESTAMP"
    echo "       └── ssh-backup_TIMESTAMP"
    echo ""
    echo "   $home_dir/"
    echo "   ├── .zshrc                # Configuração Zsh"
    echo "   ├── .oh-my-zsh/           # Framework oh-my-zsh"
    echo "   └── .fzf/                 # Fuzzy finder"
    echo ""
}

# Mostrar exemplos de configuração
show_config_examples() {
    print_step "Exemplos de configurações que serão aplicadas..."
    
    echo ""
    echo "🔧 Configuração SSH (~/.ssh/config):"
    echo "───────────────────────────────────────"
    cat << 'EOF'
Host moria
    HostName 10.11.18.100
    Port 22
    User root
    IdentityFile ~/.ssh/proxmox_key
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host lxc-101
    HostName 10.11.18.101
    Port 22
    User root
    IdentityFile ~/.ssh/proxmox_key
    IdentitiesOnly yes
EOF
    
    echo ""
    echo "🐚 Aliases Zsh que serão adicionados:"
    echo "───────────────────────────────────────"
    cat << 'EOF'
# Aliases eza
alias ll='eza -l --icons --color=always --group-directories-first'
alias la='eza -la --icons --color=always --group-directories-first'
alias lt='eza --tree --icons --color=always'

# Aliases Proxmox
alias pct-list='pct list'
alias qm-list='qm list'
alias pve-status='pvesh get /cluster/status'

# Funções úteis
ff()       # Buscar arquivos com fzf
fd()       # Buscar diretórios com fzf
fh()       # Buscar histórico com fzf
extract()  # Extrair arquivos automaticamente
sysinfo()  # Informações do sistema
EOF
    
    echo ""
}

# Demonstrar funcionalidades principais
demonstrate_features() {
    print_step "Demonstrando funcionalidades principais..."
    
    echo ""
    echo "🚀 O script oferece as seguintes funcionalidades:"
    echo ""
    echo "1️⃣  Configuração SSH automática:"
    echo "   • Geração de chaves SSH ed25519"
    echo "   • Configuração automática do ~/.ssh/config"
    echo "   • Teste de conectividade"
    echo "   • Suporte para múltiplos servidores"
    echo ""
    
    echo "2️⃣  Instalação completa do ambiente Zsh:"
    echo "   • oh-my-zsh com plugins essenciais"
    echo "   • eza (substituto moderno do ls)"
    echo "   • fzf (fuzzy finder)"
    echo "   • Tema Powerlevel10k"
    echo "   • Configurações personalizadas"
    echo ""
    
    echo "3️⃣  Gerenciamento inteligente:"
    echo "   • Detecção de instalações anteriores"
    echo "   • Backup automático de configurações"
    echo "   • Sistema de logs detalhado"
    echo "   • Verificação de mudanças no script"
    echo ""
    
    echo "4️⃣  Suporte para containers LXC:"
    echo "   • Listagem automática de containers"
    echo "   • Configuração SSH individual"
    echo "   • Instalação remota do ambiente Zsh"
    echo ""
}

# Mostrar comandos úteis
show_useful_commands() {
    print_step "Comandos úteis após a instalação..."
    
    echo ""
    echo "🔑 Acesso SSH:"
    echo "   ssh moria                    # Conectar ao Proxmox"
    echo "   ssh lxc-101                  # Conectar ao container"
    echo ""
    
    echo "🐚 Uso do Zsh:"
    echo "   source ~/.zshrc              # Recarregar configurações"
    echo "   p10k configure               # Configurar tema"
    echo "   zsh                          # Iniciar Zsh (se não for padrão)"
    echo ""
    
    echo "🔍 Busca com fzf:"
    echo "   ff arquivo                   # Buscar arquivos"
    echo "   fd diretorio                 # Buscar diretórios"
    echo "   fh                           # Buscar no histórico"
    echo "   Ctrl+T                       # Buscar arquivo (inserir path)"
    echo "   Ctrl+R                       # Buscar histórico"
    echo "   Alt+C                        # Navegar diretórios"
    echo ""
    
    echo "📊 Informações:"
    echo "   sysinfo                      # Info do sistema"
    echo "   ll                           # Listagem detalhada com eza"
    echo "   lt                           # Árvore de diretórios"
    echo ""
}

# Mostrar informações sobre logs
show_logging_info() {
    print_step "Sistema de logs e monitoramento..."
    
    echo ""
    echo "📊 O script mantém logs detalhados em ~/.proxmox-setup/"
    echo ""
    echo "Exemplo de entradas no log:"
    echo "───────────────────────────────────────"
    cat << 'EOF'
[2025-06-23 14:30:15] [INFO] Iniciando proxmox-setup.sh v1.0.0
[2025-06-23 14:30:15] [INFO] Usuário: marcus
[2025-06-23 14:30:15] [INFO] Sistema: Linux hostname 5.15.0-generic
[2025-06-23 14:30:16] [STEP] Gerando nova chave SSH...
[2025-06-23 14:30:16] [SUCCESS] Chave SSH gerada: ~/.ssh/proxmox_key.pub
[2025-06-23 14:30:17] [STEP] Configurando acesso SSH para moria...
[2025-06-23 14:30:20] [SUCCESS] Chave copiada com sucesso!
[2025-06-23 14:30:21] [SUCCESS] SSH config atualizado para moria
EOF
    echo ""
}

# Menu de demonstração interativa
interactive_demo() {
    print_step "Demonstração interativa disponível..."
    
    echo ""
    echo "🎮 Para uma demonstração interativa completa:"
    echo ""
    echo "1. Execute o script em modo dry-run:"
    echo "   ./proxmox-setup.sh --dry-run"
    echo ""
    echo "2. Ou execute o script normalmente (fará alterações reais):"
    echo "   ./proxmox-setup.sh"
    echo ""
    echo "3. Use o menu interativo para explorar as funcionalidades"
    echo ""
    
    read -p "Deseja executar o script em modo dry-run agora? [s/N]: " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        print_info "Executando em modo dry-run..."
        echo ""
        exec "$MAIN_SCRIPT" --dry-run
    else
        print_info "Demonstração concluída. Execute manualmente quando desejar."
    fi
}

# Função principal
main() {
    print_header
    
    check_main_script
    check_version
    check_dependencies
    
    echo ""
    simulate_file_structure
    show_config_examples
    demonstrate_features
    show_useful_commands
    show_logging_info
    
    echo ""
    print_success "Demonstração concluída!"
    echo ""
    
    interactive_demo
}

# Executar se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
