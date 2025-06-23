# 🚀 Proxmox Setup Scripts - Versão Interativa

Este repositório contém uma versão completamente reformulada dos scripts de configuração do Proxmox, agora com **interface interativa moderna** usando `gum` e `fzf`.

## � Arquivos Principais

### 🎯 Scripts de Produção
- **`proxmox-setup-interactive.sh`** - Script principal com interface interativa
- **`setup-environment.sh`** - Configurador de ambiente e dependências

### 🧪 Scripts de Teste e Demonstração  
- **`test-interactive.sh`** - Demonstração e teste das funcionalidades
- **`proxmox-setup.sh`** - Versão anterior (sem interface interativa)

### 📚 Documentação
- **`README-proxmox-setup.md`** - Documentação completa da versão interativa
- **`README.md`** - Este arquivo

## 🚀 Início Rápido

### 1. Configurar Ambiente
```bash
# Configurar dependências automaticamente
./setup-environment.sh
```

### 2. Executar Script Principal
```bash
# Interface interativa completa
./proxmox-setup-interactive.sh
```

### 3. Testar (Opcional)
```bash
# Demonstração das funcionalidades
./test-interactive.sh
```

## 🎨 Principais Melhorias

### ✨ Interface Moderna
- **gum**: Menus elegantes, inputs e confirmações visuais
- **fzf**: Seleção fuzzy para containers e opções
- **Cores e ícones**: Interface visual atraente
- **Navegação intuitiva**: Menus estruturados e fáceis de usar

### 🔧 Automação Inteligente
- **Detecção automática**: Instala dependências se necessário
- **Listagem de containers**: Busca automática de containers LXC
- **SSH Inteligente**: Diferencia conexões diretas e via alias configurado
- **Verificação SSH**: Testa conexões antes de configurar
- **Backup automático**: Proteção das configurações existentes

### 🎯 Funcionalidades Principais
- 🔐 **Configuração SSH** para Proxmox e containers LXC
- 🐚 **Instalação Zsh** com oh-my-zsh (em desenvolvimento)
- 📦 **Gerenciamento de pacotes extras** com seleção múltipla
- 🔧 **Backup e restore** de configurações
- 📊 **Visualização de logs** interativa

### 🆕 Última Atualização (v2.1)
- **Lógica SSH Melhorada**: Distinção correta entre conexões locais/remotas e aliases
- **Debug Aprimorado**: Logs mais detalhados para troubleshooting
- **Robustez**: Melhor tratamento de erros em conexões SSH

## 🛠️ Dependências

### Automáticas (instaladas pelo script)
- **gum** - Interface interativa elegante
- **fzf** - Fuzzy finder para seleções

### Opcionais
- **ssh** - Para conexões remotas
- **git** - Para clonagem de repositórios
- **wget/curl** - Para downloads

---

**Desenvolvido com ❤️ para simplificar a administração do Proxmox** 🚀
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
