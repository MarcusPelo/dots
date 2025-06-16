# ************************************************************
# Startup
# ************************************************************

if [[ $- == *i* ]]; then
    # This is a good place to load graphic/ascii art, display system information, etc.
    fastfetch --logo-type kitty

fi


# ************************************************************
# Env Variables
# ************************************************************

export PATH="$PATH:/home/marcus/.cargo/bin" 


# ************************************************************
# OMZ Plugins
# ************************************************************

plugins=(
    "sudo"
    "aliases"
    # "git"                     # (default)
    # "zsh-autosuggestions"     # (default)
    # "zsh-syntax-highlighting" # (default)
    # "zsh-completions"         # (default)
)

# ************************************************************
# Aliases
# ************************************************************

# Fabric
alias fabric="fabric-ai"
# Obsidian
alias govault="cd ~/notes/Vortex"
# yadm
alias ystatus="yadm status"
alias yadd="yadm add"
alias ycommit="yadm commit"
alias ypush="yadm push"
# bat
alias cat="bat"
# Hyprctl top commands
alias hyprtop="hyprctl clients"
alias hyprdevices="hyprctl devices"
alias hyprmonitors="hyprctl monitors"
# ZSH
alias zshconf="code ~/.user.zsh"
alias zshexec="exec zsh"

# ************************************************************
# Sources
# ************************************************************

# source ~/zshrc/.fabric.zsh if exists
if [ -f ~/zshrc/.fabric.zsh ]; then
    source ~/zshrc/.fabric.zsh
fi