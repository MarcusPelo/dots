# ================================================================
# 🚀 STARTUP CONFIGURATION
# ================================================================
# * Terminal initialization and welcome messages

if [[ $- == *i* ]]; then
    # * This is a good place to load graphic/ascii art, display system information, etc.
    # ? Change fastfetch parameters to customize system info display
    fastfetch --logo-type kitty
fi


# ================================================================
# 🔌 OH-MY-ZSH PLUGINS
# ================================================================
# * Additional plugins for enhanced shell functionality
# ? Uncomment plugins below to enable them

plugins=(
    "sudo"                    
    "aliases"                 
)