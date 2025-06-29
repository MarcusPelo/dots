# ================================================================
# 🌍 ENVIRONMENT VARIABLES
# ================================================================

export EDITOR=code # Set default editor to Visual Studio Code
export PATH="$PATH:/home/marcus/.cargo/bin"  # Add Rust/Cargo binaries to PATH
export PATH=~/.npm-global/bin:$PATH # Add npm global packages to PATH

export NVM_DIR="$HOME/.config/nvm" # Set NVM directory for Node Version Manager
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export GEMINI_API_KEY="AIzaSyBEX0cgLLSt8fYFNnb_3ik8b8OpOQn4c7Q"

export HYDIR="$HOME/.config/hypr"    # Set Hyprland configuration directory
