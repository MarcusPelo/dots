# 🚀 Proxmox Setup Script (Interactive Version)

Script consolidado para configuração automatizada de SSH e ambiente Zsh tanto para servidor Proxmox quanto para containers LXC, com interface interativa usando **gum** e **fzf**.

## 🎯 Novidades da Versão 2.0

### 🎨 Interface Interativa
- **gum**: Interface elegante para menus e seleções
- **fzf**: Busca fuzzy para containers e opções
- **Menus visuais**: Navegação intuitiva com cores e ícones
- **Confirmações inteligentes**: Prompts claros para ações importantes

### 🔧 Detecção Automática
- **Instalação de dependências**: Instala gum e fzf automaticamente
- **Verificação de conectividade**: Testa conexões SSH antes de configurar
- **Detecção de containers**: Lista automaticamente containers LXC do Proxmox

## 📋 Funcionalidades

### 🔐 Configuração SSH
- **Proxmox Server**: Configuração automática de chaves SSH para acesso ao servidor Proxmox
- **Containers LXC**: Configuração de SSH para containers com listagem automática via fzf
- **Verificação automática**: Detecta se chaves já estão configuradas
- **Múltiplas conexões**: Suporte para IP local, externo e customizado
- **Interface gráfica**: Seleção visual de métodos de conexão

### 🐚 Instalação Zsh (Em Desenvolvimento)
- **oh-my-zsh**: Instalação com plugins essenciais
- **Plugins inclusos**:
  - zsh-autosuggestions
  - zsh-syntax-highlighting  
  - zsh-history-substring-search
- **Ferramentas**:
  - `eza`: Substituto moderno do `ls`
  - `fzf`: Fuzzy finder
  - `Powerlevel10k`: Tema avançado
- **Configurações personalizadas**: Aliases úteis e funções
- **Backup automático**: Das configurações existentes

### 🔧 Funcionalidades Extras
- **Pacotes adicionais**: Seleção interativa de pacotes úteis com gum
- **Detecção de mudanças**: Verifica se o script foi atualizado
- **Sistema de logs**: Registro completo de todas as operações
- **Backup automático**: Configurações SSH e Zsh
- **Visualizador de logs**: Interface interativa para ver logs

## 🏗️ Configuração do Proxmox

O script está configurado para o servidor:
- **Hostname**: moria
- **IP Local**: 10.11.18.100:22
- **IP Externo**: 77.166.75.30:2223

## 📦 Dependências

### Obrigatórias
- **gum**: Interface interativa elegante
- **fzf**: Fuzzy finder para seleções

### Instalação das Dependências

#### Método Automático
O script detecta automaticamente dependências ausentes e oferece instalação automática.

#### Método Manual

**Ubuntu/Debian:**
```bash
# fzf está disponível nos repositórios
sudo apt update && sudo apt install fzf

# gum precisa ser baixado do GitHub
wget https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_x86_64.tar.gz
tar -xzf gum_Linux_x86_64.tar.gz
sudo mv gum /usr/local/bin/
```

**Arch Linux:**
```bash
sudo pacman -S fzf
yay -S gum
```

**RHEL/CentOS/Fedora:**
```bash
sudo yum install fzf
# ou
sudo dnf install fzf

# Para gum, baixe do GitHub releases
```

## 🚀 Como Usar

### Execução Básica
```bash
./proxmox-setup-interactive.sh
```

### Opções Especiais
```bash
# Verificar versão
./proxmox-setup-interactive.sh --version

# Modo dry-run (simulação)
./proxmox-setup-interactive.sh --dry-run

# Ajuda
./proxmox-setup-interactive.sh --help
```

## 🎨 Interface do Menu Principal

O script apresenta um menu visual com as seguintes opções:

```
🚀 PROXMOX SETUP SCRIPT

🔐 Configurar SSH para Proxmox
🔐 Configurar SSH para Container LXC  
🐚 Instalar Zsh no Proxmox (remoto)
🐚 Instalar Zsh em Container LXC (remoto)
🐚 Instalar Zsh localmente
📦 Gerenciar pacotes extras
🔧 Backup de chaves SSH
📊 Visualizar logs de instalação
ℹ️  Informações do sistema
❌ Sair
```

## 🌐 Configuração SSH Interativa

### Para Proxmox
1. **Seleção de Método**: Menu visual para escolher conexão
   - 🏠 Rede Local (10.11.18.100:22)
   - 🌍 Rede Externa (77.166.75.30:2223)  
   - 🔧 IP Customizado

2. **Verificação Automática**: Detecta se SSH já está configurado
3. **Configuração Guiada**: Processo step-by-step com confirmações
4. **Teste Automático**: Valida a conexão após configuração

### Para Containers LXC
1. **Busca Automática**: Lista containers automaticamente via SSH
2. **Seleção com fzf**: Interface fuzzy para escolher container
3. **Detecção de IP**: Obtém IP do container automaticamente
4. **Configuração Personalizada**: Entrada manual se necessário

## 📦 Gerenciamento de Pacotes

Seleção interativa usando gum com múltipla escolha:

- `nfs-utils`: Cliente NFS para montagem de compartilhamentos
- `cifs-utils`: Cliente CIFS/SMB para Windows shares  
- `bat`: Cat melhorado com syntax highlighting
- `htop`: Monitor de processos interativo
- `ncdu`: Analisador de uso de disco
- `tree`: Visualizador de estrutura de diretórios
- `tmux`: Multiplexador de terminal
- `vim`: Editor de texto avançado
- `nano`: Editor de texto simples
- `rsync`: Ferramenta de sincronização
- `gum`: Interface interativa para scripts

## 📊 Visualização de Logs

O script inclui um visualizador interativo de logs que utiliza o `gum pager` para navegação fácil através do histórico de operações.

## 🔍 Características Técnicas

### Segurança
- Uso de `set -euo pipefail` (strict mode)
- Verificação de comandos antes da execução
- Backup automático antes de modificações
- Validação de entrada do usuário com gum

### Interface
- **gum**: Menus elegantes, inputs e confirmações
- **fzf**: Seleção fuzzy para listas grandes
- **Cores e ícones**: Interface visual atraente
- **Feedback visual**: Indicadores de progresso e status

### Compatibilidade
- **Sistemas suportados**: Debian, Ubuntu, CentOS, RHEL, Arch
- **Arquiteturas**: x86_64, aarch64, armv7l
- **Shells**: Bash 4.0+
- **Dependências**: gum e fzf (instalação automática disponível)

### Organização
- Funções modulares e reutilizáveis
- Sistema de logging estruturado
- Configurações centralizadas
- Detecção automática do ambiente

## 📂 Estrutura de Arquivos

```
~/.proxmox-setup/
├── install.log          # Log completo das operações
├── version              # Versão da última instalação
└── backups/            # Backups das configurações
    ├── zshrc_TIMESTAMP
    ├── oh-my-zsh_TIMESTAMP
    └── ssh-backup_TIMESTAMP
```

## 🎯 Fluxo de Uso Recomendado

### Configuração Inicial
```bash
# 1. Executar o script
./proxmox-setup-interactive.sh

# 2. Configurar SSH para Proxmox (primeira opção do menu)
# 3. Testar conexão SSH
# 4. Configurar SSH para containers desejados
# 5. Instalar pacotes extras necessários
```

### Uso Cotidiano
```bash
# Acesso rápido ao Proxmox
ssh moria

# Acesso aos containers
ssh lxc-101
ssh lxc-102
```

## ⚠️ Observações Importantes

### Dependências
- **Primeira execução**: Script detecta e oferece instalar gum/fzf
- **Sem dependências**: Script não funciona sem gum e fzf
- **Instalação automática**: Disponível para a maioria dos sistemas

### Proxmox Server
- **Shell padrão**: Bash é mantido como padrão (requerimento do Proxmox)
- **Acesso ao Zsh**: Via alias `zsh` no bashrc (quando implementado)
- **Configurações específicas**: Aliases para comandos do Proxmox

### Containers LXC
- **Detecção automática**: Lista containers automaticamente se SSH funcionar
- **Entrada manual**: Fallback para entrada manual se detecção falhar
- **Flexibilidade**: Cada container pode ter configuração independente

## 🚧 Roadmap

### Em Desenvolvimento
- [ ] Instalação completa do Zsh no Proxmox
- [ ] Instalação completa do Zsh em containers LXC
- [ ] Instalação local do Zsh
- [ ] Configuração automática do Powerlevel10k
- [ ] Sistema de templates para configurações

### Futuras Melhorias
- [ ] Suporte a múltiplos servidores Proxmox
- [ ] Configuração de túneis SSH
- [ ] Integração com Ansible
- [ ] Interface web opcional

## 🆘 Solução de Problemas

### Dependências não encontradas
```bash
# Instalar manualmente
sudo apt install fzf
wget https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_x86_64.tar.gz
```

### SSH não funciona
1. Verificar conectividade: `ping <ip_do_servidor>`
2. Verificar configuração: `ssh -vvv moria`
3. Verificar logs: usar opção de visualizar logs no menu

### Interface não aparece corretamente
1. Verificar se gum está instalado: `gum --version`
2. Verificar terminal suporta cores: `echo $TERM`
3. Redimensionar terminal para pelo menos 80 colunas

## 📝 Exemplo de Sessão Completa

```bash
# 1. Iniciar script
./proxmox-setup-interactive.sh

# Interface aparece automaticamente:
# ┌─ 🚀 PROXMOX SETUP SCRIPT ─┐
# │                           │  
# │ Configuração automatizada │
# │ Versão: 2.0.0            │
# └───────────────────────────┘

# 2. Selecionar "🔐 Configurar SSH para Proxmox"
# 3. Escolher "🏠 Rede Local" 
# 4. Confirmar configuração
# 5. Testar conexão

# Resultado: SSH configurado e testado!
```

## 🔧 Customização

Para personalizar o script para seu ambiente:

1. **Configurações do Proxmox**: Edite as variáveis no início do script
2. **Pacotes extras**: Modifique o array `EXTRA_PACKAGES`
3. **Cores e estilo**: Ajuste as configurações do gum
4. **Layouts fzf**: Customize as opções do fzf

## 🎉 Resultado Final

Após a execução completa, você terá:

✅ Interface interativa elegante com gum e fzf  
✅ Acesso SSH configurado e testado automaticamente  
✅ Detecção automática de containers LXC  
✅ Seleção visual de pacotes extras  
✅ Sistema de logs com visualizador interativo  
✅ Backup automático das configurações  
✅ Navegação intuitiva entre todas as funcionalidades  

---

**Desenvolvido para facilitar a configuração e manutenção do ambiente Proxmox e containers LXC com interface moderna e intuitiva** 🚀

### 🐚 Instalação Zsh
- **oh-my-zsh**: Instalação com plugins essenciais
- **Plugins inclusos**:
  - zsh-autosuggestions
  - zsh-syntax-highlighting  
  - zsh-history-substring-search
- **Ferramentas**:
  - `eza`: Substituto moderno do `ls`
  - `fzf`: Fuzzy finder
  - `Powerlevel10k`: Tema avançado
- **Configurações personalizadas**: Aliases úteis e funções
- **Backup automático**: Das configurações existentes

### 🔧 Funcionalidades Extras
- **Pacotes adicionais**: Seleção de pacotes úteis (nfs-utils, cifs-utils, bat, etc.)
- **Detecção de mudanças**: Verifica se o script foi atualizado
- **Sistema de logs**: Registro completo de todas as operações
- **Backup automático**: Configurações SSH e Zsh

## 🏗️ Configuração do Proxmox

O script está configurado para o servidor:
- **Hostname**: moria
- **IP Local**: 10.11.18.100:22
- **IP Externo**: 77.166.75.30:2223

## 🚀 Como Usar

### Execução Básica
```bash
./proxmox-setup.sh
```

### Opções Especiais
```bash
# Verificar versão
./proxmox-setup.sh --version

# Modo dry-run (simulação)
./proxmox-setup.sh --dry-run
```

## 📋 Menu Principal

```
🔐 CONFIGURAÇÃO SSH:
  1) Configurar SSH para Proxmox
  2) Configurar SSH para Container LXC

🐚 INSTALAÇÃO ZSH:
  3) Instalar Zsh no Proxmox (remoto)
  4) Instalar Zsh em Container LXC (remoto)
  5) Instalar Zsh localmente

🔧 UTILITÁRIOS:
  6) Backup de chaves SSH
  7) Visualizar logs de instalação
  8) Informações do sistema
```

## 📦 Pacotes Extras Disponíveis

O script oferece a instalação opcional dos seguintes pacotes:

- `nfs-utils`: Cliente NFS
- `cifs-utils`: Cliente CIFS/SMB  
- `bat`: Cat com syntax highlighting
- `htop`: Monitor de processos
- `ncdu`: Analisador de espaço em disco
- `tree`: Visualizar estrutura de diretórios
- `tmux`: Multiplexador de terminal
- `vim`: Editor de texto avançado
- `nano`: Editor de texto simples
- `rsync`: Sincronização de arquivos

## 🔍 Características Técnicas

### Segurança
- Uso de `set -euo pipefail` (strict mode)
- Verificação de comandos antes da execução
- Backup automático antes de modificações
- Validação de entrada do usuário

### Compatibilidade
- **Sistemas suportados**: Debian, Ubuntu, CentOS, RHEL, Arch
- **Arquiteturas**: x86_64, aarch64, armv7l
- **Shells**: Bash 4.0+

### Organização
- Funções modulares e reutilizáveis
- Sistema de logging estruturado
- Configurações centralizadas
- Detecção automática do ambiente

## 📂 Estrutura de Arquivos

```
~/.proxmox-setup/
├── install.log          # Log completo das operações
├── version              # Versão da última instalação
└── backups/            # Backups das configurações
    ├── zshrc_TIMESTAMP
    ├── oh-my-zsh_TIMESTAMP
    └── ssh-backup_TIMESTAMP
```

## 🎯 Aliases e Funções Instaladas

### Aliases do eza
```bash
ls='eza --color=always --group-directories-first'
ll='eza -l --icons --color=always --group-directories-first'
la='eza -la --icons --color=always --group-directories-first'
lt='eza --tree --icons --color=always'
```

### Aliases do Proxmox
```bash
pct-list='pct list'
qm-list='qm list'
pve-status='pvesh get /cluster/status'
```

### Funções Úteis
```bash
ff <nome>           # Buscar arquivos
fd <nome>           # Buscar diretórios
fh                  # Buscar no histórico
extract <arquivo>   # Extrair arquivos
sysinfo            # Informações do sistema
```

## ⚠️ Observações Importantes

### Proxmox Server
- **Shell padrão**: Bash é mantido como padrão (requerimento do Proxmox)
- **Acesso ao Zsh**: Via alias `zsh` no bashrc
- **Configurações específicas**: Aliases para comandos do Proxmox

### Containers LXC
- **Shell padrão**: Opção de configurar Zsh como padrão
- **Flexibilidade**: Cada container pode ter configuração independente

### Execução Local
- **Requisitos**: Alguns recursos requerem privilégios root
- **Instalação**: Funciona mesmo sem root (com limitações)

## 🔄 Sistema de Atualização

O script detecta automaticamente quando foi modificado e oferece:
- Verificação de hash do script
- Comparação de versões
- Opção de atualização das configurações
- Preservação de customizações do usuário

## 📊 Logs e Monitoramento

Todas as operações são registradas em `~/.proxmox-setup/install.log` com:
- Timestamp de cada operação
- Nível de log (INFO, SUCCESS, WARNING, ERROR)
- Detalhes completos das execuções
- Hash do script para controle de versão

## 🆘 Solução de Problemas

### SSH não funciona
1. Verifique conectividade: `ping <ip_do_servidor>`
2. Teste conexão manual: `ssh -p <porta> root@<ip>`
3. Verifique logs: opção 7 do menu

### Instalação do Zsh falha
1. Verifique conexão de internet
2. Execute como root se necessário
3. Verifique logs para erros específicos

### Permissões
- SSH: Script configura permissões automaticamente
- Zsh: Alguns recursos requerem privilégios elevados

## 🔧 Customização

Para personalizar o script para seu ambiente:

1. **Configurações do Proxmox**: Edite as variáveis no início do script
2. **Pacotes extras**: Modifique o array `EXTRA_PACKAGES`
3. **Configurações Zsh**: Customize a função `configure_zshrc`

## 📝 Exemplo de Uso Completo

```bash
# 1. Executar o script
./proxmox-setup.sh

# 2. Configurar SSH para Proxmox (opção 1)
# 3. Instalar Zsh no Proxmox (opção 3)
# 4. Configurar SSH para container (opção 2)
# 5. Instalar Zsh no container (opção 4)

# Testar conexões
ssh moria
ssh lxc-101

# Aplicar configurações
source ~/.zshrc
p10k configure
```

## 🔧 Atualizações e Melhorias

### Lógica SSH Aprimorada (v2.1)
- **Distinção Local vs Remoto**: A função `test_ssh_connection()` agora diferencia corretamente entre:
  - Conexões diretas (IP + porta): `ssh -p PORT IP`
  - Conexões via alias SSH configurado: `ssh ALIAS`
- **Consistência**: Configuração inicial usa IP/porta direta, testes subsequentes usam alias configurado
- **Melhor Debug**: Logs mais detalhados sobre o tipo de conexão sendo testada
- **Robustez**: Tratamento de erro melhorado para diferentes tipos de conexão

### Detecção de Dependências
- Auto-instalação robusta de `gum` e `fzf`
- Fallback para instalação manual se repositórios falharem
- Detecção inteligente de versões e arquiteturas

## 🎉 Resultado Final

Após a execução completa, você terá:

✅ Acesso SSH configurado e testado  
✅ Ambiente Zsh completo com oh-my-zsh  
✅ Ferramentas modernas (eza, fzf)  
✅ Tema Powerlevel10k  
✅ Aliases e funções úteis  
✅ Backup das configurações anteriores  
✅ Logs detalhados de toda a instalação  

---

**Desenvolvido para facilitar a configuração e manutenção do ambiente Proxmox e containers LXC** 🚀
