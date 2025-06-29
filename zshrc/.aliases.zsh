# ================================================================
# 🔗 COMMAND ALIASES
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
alias ycommit="yadm commit -am"                     # Commit changes with message
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