# 🏠 Dotfiles - Marcus

## 📋 Overview

Este repositório contém as configurações pessoais (dotfiles) gerenciados via [yadm](https://yadm.io/), organizando um ambiente de trabalho moderno e produtivo baseado em Hyprland (Wayland).

## 🖥️ Setup Principal

### Desktop Environment
- **Window Manager**: Hyprland (baseado no projeto HyDE)
- **Terminal**: Kitty com configurações customizadas
- **Shell**: Zsh com Oh My Zsh
- **Browser**: Zen Browser com extensões produtividade
- **Status Bar**: Waybar com módulos personalizados

### Aplicações & Ferramentas
- **Editor Principal**: Visual Studio Code
- **AI Assistant**: Fabric (danielmiessler/fabric) com 200+ patterns
- **Launcher**: Rofi com temas customizados
- **Controle Audio**: PavuControl via scratchpads
- **Notas**: Obsidian (integrado via scratchpads)
- **Música**: Spotify (via scratchpad)

## 📁 Estrutura Principal

```
.config/
├── hypr/               # Configurações Hyprland
│   ├── hyprland.conf   # Configuração principal
│   ├── keybindings.conf # Atalhos de teclado
│   ├── pyprland.toml   # Scratchpads e plugins
│   ├── animations/     # Presets de animação
│   └── themes/         # Temas e cores
├── kitty/              # Terminal Kitty
├── fabric/             # AI Patterns e Scripts
│   ├── patterns/       # 200+ patterns para IA
│   └── fabric-ai-helper.sh # Script interativo
├── waybar/             # Barra de status
└── rofi/               # Launcher
.zen/Pelo/              # Zen Browser (perfil Pelo)
.zshrc                  # Shell principal
.user.zsh               # Configurações pessoais ZSH
zshrc/                  # Módulos ZSH adicionais
└── .fabric.zsh         # Aliases dinâmicos para Fabric AI
```

## ✨ Features Principais

### 🎯 Scratchpads (via pyprland)
- **Terminal**: Kitty dropdown (75% x 60%)
- **SSH**: Acesso rápido ao servidor Moria
- **Volume**: Controle PavuControl (lateral direita)
- **Obsidian**: Vault Vortex para notas
- **Spotify**: Player musical

### 🤖 Fabric AI Integration
- 200+ patterns para análise, criação e processamento de conteúdo
- Script interativo com menu `gum` para fácil uso
- **Aliases dinâmicos**: Cada pattern vira um comando zsh automático
- Integração com Obsidian para organização de outputs
- Patterns para código, documentação, análise e muito mais
- **YouTube Integration**: Comando `yt` para transcrever vídeos

#### Comandos Fabric Disponíveis
- `[pattern_name] "título"` → Salva output no Obsidian com data
- `[pattern_name]` → Executa em modo stream (tempo real)
- `yt [-t] youtube-link` → Transcreve vídeos (com/sem timestamps)

### 🎨 Customizações Visuais
- Múltiplos presets de animação (classic, diablo, minimal, etc.)
- Temas dinâmicos via wallbash
- Shaders personalizados (blue-light-filter, grayscale, etc.)
- Hyprlock personalizado

### 🌐 Zen Browser Setup
- Sidebar com acesso rápido: ChatGPT, Perplexity, Notion, Gemini
- Split views configurados (Grid, Vertical, Horizontal)
- Workspaces com containers específicos
- Tema AMOLED personalizado

## 🚀 Workflows

### 📝 Editing Workflow
- Hyprland workspace dedicado para desenvolvimento
- VS Code como editor principal
- Kitty para terminal
- Obsidian para documentação

### 🎮 Gaming Workflow
- Configurações otimizadas para jogos
- Power management dedicado

### ⚡ Powersaver Workflow
- Modo economia de energia
- Animações reduzidas

## 🛠️ Tecnologias Utilizadas

- **yadm**: Gerenciamento de dotfiles
- **HyDE**: Base do ambiente Hyprland
- **pyprland**: Plugins e scratchpads
- **gum**: Interface interativa para scripts
- **fzf**: Fuzzy finder
- **fastfetch**: Informações do sistema
- **fabric**: Framework AI com aliases dinâmicos para 200+ patterns

## 📦 Dependências Principais

```bash
# Core
hyprland kitty zsh waybar rofi

# AI & Productivity  
fabric-ai gum fzf obsidian

# Utilities
pavucontrol zen-browser fastfetch
```

## 🎯 Atalhos Importantes

- **Super + Return**: Terminal (scratchpad)
- **Super + B**: Browser (Zen)
- **Super + E**: File Manager
- **Ctrl + Alt + C**: Compact Mode Toggle
- **Alt + A**: Web Panels Toggle

## 📅 Histórico

- **Último Update**: Junho 2025
- **Commits Recentes**:
  - Add Spotify scratchpad
  - New pypr scratchpads for Obsidian
  - Fabric Helper Script integration
  - Zen Browser configurations

---

*Gerenciado com ❤️ via yadm*
