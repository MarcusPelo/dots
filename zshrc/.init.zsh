
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


# * Function to run hyprctl clients command with optional filtering
#  Usage: run_hypr_clients [filter_type] [filter_value] [format]
#  Examples:
#    run_hypr_clients                    # Show all clients (default)
#    run_hypr_clients class firefox      # Filter by class containing "firefox"
#    run_hypr_clients title "Terminal"   # Filter by title containing "Terminal"
#    run_hypr_clients workspace 1       # Filter by workspace 1
#    run_hypr_clients pid 1234          # Filter by specific PID
#    run_hypr_clients --json            # Output in JSON format
#    run_hypr_clients --simple          # Simple format (class and title only)
function run_hypr_clients() {
    local filter_type=""
    local filter_value=""
    local output_format="default"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --json)
                output_format="json"
                shift
                ;;
            --simple)
                output_format="simple"
                shift
                ;;
            --help|-h)
                echo "Usage: run_hypr_clients [options] [filter_type] [filter_value]"
                echo ""
                echo "Options:"
                echo "  --json     Output in JSON format"
                echo "  --simple   Simple format (class and title only)"
                echo "  --help     Show this help message"
                echo ""
                echo "Filter types:"
                echo "  class      Filter by window class"
                echo "  title      Filter by window title"
                echo "  workspace  Filter by workspace number"
                echo "  pid        Filter by process ID"
                echo ""
                echo "Examples:"
                echo "  run_hypr_clients"
                echo "  run_hypr_clients class firefox"
                echo "  run_hypr_clients title Terminal"
                echo "  run_hypr_clients workspace 1"
                echo "  run_hypr_clients --simple class code"
                return 0
                ;;
            class|title|workspace|pid)
                filter_type="$1"
                filter_value="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                return 1
                ;;
        esac
    done
    
    # Get clients data
    local clients_output
    if [[ "$output_format" == "json" ]]; then
        clients_output=$(hyprctl clients -j)
    else
        clients_output=$(hyprctl clients)
    fi
    
    # Apply filtering
    if [[ -n "$filter_type" && -n "$filter_value" ]]; then
        case "$filter_type" in
            class)
                if [[ "$output_format" == "json" ]]; then
                    clients_output=$(echo "$clients_output" | jq --arg class "$filter_value" '[.[] | select(.class | test($class; "i"))]')
                else
                    clients_output=$(echo "$clients_output" | grep -i "class: .*$filter_value")
                fi
                ;;
            title)
                if [[ "$output_format" == "json" ]]; then
                    clients_output=$(echo "$clients_output" | jq --arg title "$filter_value" '[.[] | select(.title | test($title; "i"))]')
                else
                    clients_output=$(echo "$clients_output" | grep -i "title: .*$filter_value")
                fi
                ;;
            workspace)
                if [[ "$output_format" == "json" ]]; then
                    clients_output=$(echo "$clients_output" | jq --arg ws "$filter_value" '[.[] | select(.workspace.id == ($ws | tonumber))]')
                else
                    clients_output=$(echo "$clients_output" | grep "workspace: $filter_value ")
                fi
                ;;
            pid)
                if [[ "$output_format" == "json" ]]; then
                    clients_output=$(echo "$clients_output" | jq --arg pid "$filter_value" '[.[] | select(.pid == ($pid | tonumber))]')
                else
                    clients_output=$(echo "$clients_output" | grep "pid: $filter_value")
                fi
                ;;
        esac
    fi
    
    # Format output
    case "$output_format" in
        json)
            echo "$clients_output" | jq '.'
            ;;
        simple)
            if [[ -n "$filter_type" ]]; then
                # If filtering was applied, we need to get the full data and extract simple info
                hyprctl clients | grep -A 10 -B 10 "$filter_value" | \
                awk '
                /^Window/ { window_line = $0 }
                /class: / { class = substr($0, index($0, ": ") + 2) }
                /title: / { 
                    title = substr($0, index($0, ": ") + 2)
                    if (class && title) {
                        printf "%-20s | %s\n", class, title
                        class = ""
                        title = ""
                    }
                }'
            else
                hyprctl clients | awk '
                /class: / { class = substr($0, index($0, ": ") + 2) }
                /title: / { 
                    title = substr($0, index($0, ": ") + 2)
                    if (class && title) {
                        printf "%-20s | %s\n", class, title
                        class = ""
                        title = ""
                    }
                }'
            fi
            ;;
        default)
            echo "$clients_output" | grep -v "^\s*$" | grep -v "^\s*#"
            ;;
    esac
}

zle -N run_hypr_clients
