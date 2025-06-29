# ================================================================
# 📂 SOURCE EXTERNAL CONFIGURATIONS
# ================================================================
# * Load additional configuration files

# * Source fabric AI configuration if it exists
# ? Contains dynamic pattern functions and YouTube transcript tools
if [ -f ~/zshrc/.fabric.zsh ]; then
    source ~/zshrc/.fabric.zsh
fi


# * Function to check dotfiles status using yadm
function run_ystatus() {
    yadm status
}
zle -N run_ystatus