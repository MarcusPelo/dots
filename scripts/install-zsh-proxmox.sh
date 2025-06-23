#!/bin/bash

# 🚀 Script de instalação completa do oh-my-zsh, eza e fzf para Proxmox
# Execute este script no servidor Proxmox

set -e  # Parar em caso de erro

echo "🔧 Iniciando configuração do ambiente Zsh no Proxmox..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}🔸 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Atualizar sistema
print_step "Atualizando sistema..."
apt update && apt upgrade -y
print_success "Sistema atualizado"

# 2. Instalar dependências
print_step "Instalando dependências..."
apt install -y curl wget git zsh unzip build-essential
print_success "Dependências instaladas"

# 3. Instalar oh-my-zsh
print_step "Instalando oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh instalado"
else
    print_warning "oh-my-zsh já está instalado"
fi

# 4. Instalar plugins essenciais
print_step "Instalando plugins do zsh..."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions instalado"
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting instalado"
fi

# zsh-history-substring-search
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    print_success "zsh-history-substring-search instalado"
fi

# 5. Instalar eza (substituto moderno do ls)
print_step "Instalando eza..."
if ! command -v eza &> /dev/null; then
    # Baixar e instalar eza
    EZA_VERSION=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    wget -q "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz" -O /tmp/eza.tar.gz
    tar -xzf /tmp/eza.tar.gz -C /tmp/
    mv /tmp/eza /usr/local/bin/
    chmod +x /usr/local/bin/eza
    rm /tmp/eza.tar.gz
    print_success "eza instalado (versão $EZA_VERSION)"
else
    print_warning "eza já está instalado"
fi

# 6. Instalar fzf (fuzzy finder)
print_step "Instalando fzf..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
    print_success "fzf instalado"
else
    print_warning "fzf já está instalado"
fi

# 7. Configurar .zshrc
print_step "Configurando .zshrc..."
cat > ~/.zshrc << 'EOF'
# Configuração do oh-my-zsh para Proxmox Server
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

# ===============================
# CONFIGURAÇÕES PERSONALIZADAS
# ===============================

# Aliases para eza
if command -v eza &> /dev/null; then
    alias ls='eza'
    alias ll='eza -l --icons'
    alias la='eza -la --icons'
    alias lt='eza --tree --icons'
    alias llt='eza -l --tree --icons'
fi

# Aliases úteis para Proxmox
alias pct-list='pct list'
alias qm-list='qm list'
alias pve-status='pvesh get /cluster/status'
alias storage-status='pvesh get /storage'
alias node-status='pvesh get /nodes'

# Aliases gerais
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

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

# fzf configuração
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Configurações do fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'cat {}' --preview-window=right:60%"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# Função para busca rápida de arquivos
ff() {
    find . -type f -name "*$1*" | fzf --preview 'cat {}'
}

# Função para busca rápida de diretórios
fd() {
    find . -type d -name "*$1*" | fzf
}

# Função para histórico com fzf
fh() {
    eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# Prompt personalizado
PROMPT='%{$fg[cyan]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[cyan]%}]%{$reset_color%}$ '

# Informações do sistema no login
echo -e "\n${BLUE}🏗️  Proxmox Server - $(hostname)${NC}"
echo -e "${GREEN}📊 Sistema: $(uname -sr)${NC}"
echo -e "${YELLOW}💾 Uptime: $(uptime -p)${NC}"
echo -e "${PURPLE}🔧 Shell: $SHELL${NC}\n"
EOF

print_success ".zshrc configurado"

# 8. Definir zsh como shell padrão
print_step "Definindo zsh como shell padrão..."
if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s $(which zsh)
    print_success "Zsh definido como shell padrão"
else
    print_warning "Zsh já é o shell padrão"
fi

# 9. Instalar tema PowerLevel10k (opcional)
print_step "Instalando tema Powerlevel10k..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    
    # Atualizar tema no .zshrc
    sed -i 's/ZSH_THEME="agnoster"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    print_success "Powerlevel10k instalado"
else
    print_warning "Powerlevel10k já está instalado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "🎉 Instalação concluída com sucesso!"
echo ""
echo -e "${CYAN}📋 O que foi instalado:${NC}"
echo "  ✅ oh-my-zsh com plugins essenciais"
echo "  ✅ eza (substituto moderno do ls)"
echo "  ✅ fzf (fuzzy finder)"
echo "  ✅ Tema Powerlevel10k"
echo "  ✅ Configurações personalizadas"
echo ""
echo -e "${YELLOW}🔄 Para aplicar as mudanças:${NC}"
echo "  1. Execute: source ~/.zshrc"
echo "  2. Ou faça logout/login"
echo "  3. Configure o Powerlevel10k: p10k configure"
echo ""
echo -e "${PURPLE}🎯 Comandos úteis adicionados:${NC}"
echo "  • ff <nome>    - Buscar arquivos"
echo "  • fd <nome>    - Buscar diretórios"
echo "  • fh           - Buscar no histórico"
echo "  • ll, la, lt   - Listagens com eza"
echo ""
EOF
