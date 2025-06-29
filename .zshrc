
export EDITOR=code
# ================================================================
# 🌍 ENVIRONMENT VARIABLES
# ================================================================
# * System-wide environment configuration

# * Add Rust/Cargo binaries to PATH
export PATH="$PATH:/home/marcus/.cargo/bin" 



# ================================================================
# 🔗 COMMAND ALIASES
# ================================================================

# ================================================================
# 🔧 CUSTOM ALIAS OVERRIDES (PRIORITY SECTION)
# ================================================================
# * Custom aliases that override plugin defaults
# ? These are defined early to ensure they take precedence over plugin aliases
# ! The 'aliases' plugin defines: ll='ls -alF', la='ls -A', l='ls -CF'
# ! Our eza aliases below will override those defaults

# * ──────────────────────────────────────────────────────────────
# * eza aliases (Override 'aliases' plugin defaults)
# * ──────────────────────────────────────────────────────────────
alias l="eza  --icons=auto --sort=name  --group-directories-first"
alias ls='eza -lh --icons=auto --sort=name  --group-directories-first' 
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' 
alias la='eza -lha --icons=auto --sort=name --group-directories-first -d .*' 
alias ld='eza -lhD --icons=auto --sort=name  --group-directories-first' 
alias lt='eza --icons=auto --tree'

# ================================================================
# 🔗 OTHER COMMAND ALIASES
# ================================================================
# * Custom shortcuts and command improvements

# * ──────────────────────────────────────────────────────────────
# * 🤖 Fabric AI Aliases
# * ──────────────────────────────────────────────────────────────
alias fabric="fabric-ai"                           # Use fabric-ai as fabric command
alias fabric-helper="~/.config/fabric/fabric-ai-helper.sh"  # Interactive fabric helper script

# * ──────────────────────────────────────────────────────────────
# * 📚 Obsidian Vault Navigation
# * ──────────────────────────────────────────────────────────────
alias govault="cd ~/notes/Vortex"                  # Quick navigation to Obsidian vault

# * ──────────────────────────────────────────────────────────────
# * 📦 YADM (Yet Another Dotfiles Manager)
# * ──────────────────────────────────────────────────────────────
alias ystatus="yadm status"                        # Check dotfiles status
alias yadd="yadm add"                              # Add files to dotfiles repo
alias ycommit="yadm commit -am"                    # Commit changes with message
alias ypush="yadm push"                            # Push dotfiles to remote

# * ──────────────────────────────────────────────────────────────
# * 📄 File Operations
# * ──────────────────────────────────────────────────────────────
alias cat="bat"                                    # Use bat for syntax highlighting

# * ──────────────────────────────────────────────────────────────
# * 🪟 Hyprland Control Commands
# * ──────────────────────────────────────────────────────────────
alias hyprtop="hyprctl clients"                    # List all open windows
alias hyprdevices="hyprctl devices"                # Show input devices
alias hyprmonitors="hyprctl monitors"              # Display monitor information

# * ──────────────────────────────────────────────────────────────
# * 🐚 ZSH Configuration
# * ──────────────────────────────────────────────────────────────
alias zshconf="code ~/.user.zsh"                   # Edit ZSH configuration
alias zshexec="exec zsh"                           # Reload ZSH configuration

# ================================================================
# 📂 SOURCE EXTERNAL CONFIGURATIONS
# ================================================================
# * Load additional configuration files

# * Source fabric AI configuration if it exists
# ? Contains dynamic pattern functions and YouTube transcript tools
if [ -f ~/zshrc/.fabric.zsh ]; then
    source ~/zshrc/.fabric.zsh
fi

# TODO: Add more configuration sources as needed
# TODO: Consider organizing sources by category (tools, themes, etc.)
export PATH=~/.npm-global/bin:$PATH

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
