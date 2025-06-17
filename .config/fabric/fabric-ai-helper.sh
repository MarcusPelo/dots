#!/bin/bash

# ================================================================
# FABRIC AI HELPER SCRIPT
# ================================================================
# A robust shell script for interacting with fabric-ai patterns
# Author: GitHub Copilot
# Date: 2025-06-16
# 
# Features:
# - Interactive pattern selection with fzf
# - Automatic file management with organized outputs
# - Obsidian integration for seamless note-taking
# - Multi-format viewing options (terminal, VSCode, Obsidian)
# ================================================================

# ! Exit on error, undefined variables, and pipe failures
set -euo pipefail

# ================================================================
# 🌍 GLOBAL VARIABLES & CONFIGURATION
# ================================================================

# * Base directories for input and output files
readonly INPUT_DIR="/home/marcus/notes/Vortex/99-Setup/Al Chat History/_input"
readonly OUTPUT_DIR="/home/marcus/notes/Vortex/99-Setup/Al Chat History"

# * Load fabric configuration from .env file
FABRIC_CONFIG_DIR="${HOME}/.config/fabric"
if [[ -f "${FABRIC_CONFIG_DIR}/.env" ]]; then
    # ? Source the .env file to get fabric defaults
    source "${FABRIC_CONFIG_DIR}/.env"
    readonly DEFAULT_AGENT="${DEFAULT_VENDOR:-Gemini}"
    readonly DEFAULT_MODEL="${DEFAULT_MODEL:-gemini-2.5-flash-preview-05-20}"
    readonly DEFAULT_LANGUAGE="${LANGUAGE_OUTPUT:-en-US}"
else
    # ! Fallback values if .env not found
    readonly DEFAULT_AGENT="Gemini"
    readonly DEFAULT_MODEL="gemini-2.5-flash-preview-05-20"
    readonly DEFAULT_LANGUAGE="en-US"
fi

# * Colors for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# ================================================================
# 🛠️  UTILITY FUNCTIONS
# ================================================================

# * Print colored messages for better user feedback
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}    Fabric AI Helper Script${NC}"
    echo -e "${PURPLE}================================${NC}"
    echo
}

# * Check if required dependencies are installed
# ! Critical function - script will not work without these tools
check_dependencies() {
    local deps=("gum" "fzf" "fabric-ai")
    local missing_deps=()
    
    # * Check all dependencies
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install the missing dependencies and try again."
        print_info "- gum: https://github.com/charmbracelet/gum"
        print_info "- fzf: https://github.com/junegunn/fzf"
        print_info "- fabric-ai: https://github.com/danielmiessler/fabric"
        exit 1
    else
        print_success "All dependencies found!"
    fi
}

# * Ensure required directories exist
# ? Creates directories if they don't exist (with user confirmation)
ensure_directories() {
    if [[ ! -d "$INPUT_DIR" ]]; then
        print_warning "Input directory does not exist: $INPUT_DIR"
        if gum confirm "Create input directory?"; then
            mkdir -p "$INPUT_DIR"
            print_success "Created input directory: $INPUT_DIR"
        else
            print_error "Input directory is required for operation."
            exit 1
        fi
    fi
    
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        print_warning "Output directory does not exist: $OUTPUT_DIR"
        if gum confirm "Create output directory?"; then
            mkdir -p "$OUTPUT_DIR"
            print_success "Created output directory: $OUTPUT_DIR"
        else
            print_error "Output directory is required for operation."
            exit 1
        fi
    fi
}

# * Get available text viewer command (priority: less > more > cat)
get_text_viewer() {
    if command -v less &> /dev/null; then
        echo "less"
    elif command -v more &> /dev/null; then
        echo "more"
    elif command -v cat &> /dev/null; then
        echo "cat"
    else
        echo "cat"  # fallback to cat which should always be available
    fi
}

# * Get current date in YYYY-MM-DD format for file naming
get_current_date() {
    date +"%Y-%m-%d"
}

# * Open file in Obsidian using URI scheme
# ? Requires Obsidian to be installed and xdg-open to be available
open_in_obsidian() {
    local file_path="$1"
    local vault_name="Vortex"  # * Your Obsidian vault name
    
    # ? Check if we can open URIs (basic check)
    if ! command -v xdg-open &> /dev/null; then
        print_error "xdg-open not available. Cannot open Obsidian URI."
        return 1
    fi
    
    # * Get the relative path from the vault root
    local vault_root="/home/marcus/notes/Vortex"
    local relative_path
    
    if [[ "$file_path" == "$vault_root"* ]]; then
        # * Remove vault root from path to get relative path
        relative_path="${file_path#$vault_root/}"
        
        # * URL encode the path for URI
        local encoded_path
        if command -v jq &> /dev/null; then
            encoded_path=$(printf '%s' "$relative_path" | jq -sRr @uri)
        elif command -v python3 &> /dev/null; then
            encoded_path=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$relative_path'))")
        else
            # ? Fallback: basic encoding for spaces
            encoded_path="${relative_path// /%20}"
        fi
        
        # * Use Obsidian URI to open the file
        local obsidian_uri="obsidian://open?vault=${vault_name}&file=${encoded_path}"
        
        print_info "Opening in Obsidian: $relative_path"
        print_info "URI: $obsidian_uri"
        xdg-open "$obsidian_uri" >/dev/null 2>&1 &
        disown
    else
        print_warning "File is not in Obsidian vault ($vault_root)"
        print_warning "Using fallback method"
        xdg-open "$file_path" >/dev/null 2>&1 &
        disown
    fi
}

# * Validate filename and add .md extension if needed
# ! Security function - removes dangerous characters and path components
validate_filename() {
    local filename="$1"
    
    # ! Remove any path components for security
    filename=$(basename "$filename")
    
    # * Add .md extension if not present
    if [[ ! "$filename" =~ \.md$ ]]; then
        filename="${filename}.md"
    fi
    
    # ! Remove any dangerous characters
    filename=$(echo "$filename" | tr -d '[:cntrl:]' | tr -s ' ' '_')
    
    echo "$filename"
}

# ================================================================
# 🤖 FABRIC AI FUNCTIONS
# ================================================================

# * Get list of available fabric patterns
# ? Tries multiple methods to retrieve patterns
get_fabric_patterns() {
    local patterns
    
    # * Try to get patterns from fabric-ai command (using the actual binary)
    if patterns=$(fabric-ai --listpatterns 2>/dev/null); then
        echo "$patterns"
    elif patterns=$(fabric-ai --list-patterns 2>/dev/null); then
        echo "$patterns"
    else
        # ? Try to get patterns from the local patterns directory
        local patterns_dir="${HOME}/.config/fabric/patterns"
        if [[ -d "$patterns_dir" ]]; then
            print_info "Using patterns from local patterns directory"
            find "$patterns_dir" -maxdepth 1 -type d ! -name "." ! -name ".." -exec basename {} \; | sort
        else
            # ! Fallback to common patterns if command fails
            print_warning "Could not retrieve patterns from fabric-ai, using fallback list."
            cat << EOF
analyze_claims
brainstorm
code_generator
create_coding_feature
creative_writing
extract_wisdom
improve_writing
summarize
write_essay
write_latex
EOF
        fi
    fi
}

# * Select a user prompt file from input directory
# ? Uses fzf for interactive file selection
select_prompt_file() {
    local files
    
    # * Get all .md files in input directory
    files=$(find "$INPUT_DIR" -name "*.md" -type f 2>/dev/null | sort)
    
    if [[ -z "$files" ]]; then
        print_error "No .md files found in input directory: $INPUT_DIR"
        return 1
    fi
    
    # * Use fzf to select file
    local selected_file
    selected_file=$(echo "$files" | fzf --prompt="Select input file: " --height=10 --border)
    
    if [[ -n "$selected_file" && -r "$selected_file" ]]; then
        echo "$selected_file"
        return 0
    else
        print_error "No file selected or file is not readable."
        return 1
    fi
}

# * Select a fabric pattern using interactive menu
# ? Returns the selected pattern name or exits on failure
select_fabric_pattern() {
    local patterns
    patterns=$(get_fabric_patterns)
    
    if [[ -z "$patterns" ]]; then
        print_error "No patterns available."
        return 1
    fi
    
    # * Use fzf to select pattern
    local selected_pattern
    selected_pattern=$(echo "$patterns" | fzf --prompt="Select pattern: " --height=15 --border)
    
    if [[ -n "$selected_pattern" ]]; then
        echo "$selected_pattern"
        return 0
    else
        print_error "No pattern selected."
        return 1
    fi
}

# * Get output language from user
# ? Uses default from .env file if no input provided
get_output_language() {
    local language
    
    # * Prompt for language with default from .env
    language=$(gum input --placeholder "$DEFAULT_LANGUAGE" --prompt "Output language (default: $DEFAULT_LANGUAGE): ")
    
    # * Use default if empty
    if [[ -z "$language" ]]; then
        language="$DEFAULT_LANGUAGE"
    fi
    
    echo "$language"
}

# * Get output filename from user
# ! Validates filename and checks for existing files
get_output_filename() {
    local filename
    local full_path
    
    # * Prompt for filename
    filename=$(gum input --prompt "Output filename (without .md): ")
    
    if [[ -z "$filename" ]]; then
        print_error "Filename cannot be empty."
        return 1
    fi
    
    # * Validate and format filename
    filename=$(validate_filename "$filename")
    full_path="$OUTPUT_DIR/$filename"
    
    # ? Check if file already exists
    if [[ -f "$full_path" ]]; then
        print_warning "File already exists: $filename"
        if ! gum confirm "Overwrite existing file?"; then
            print_info "Operation cancelled."
            return 1
        fi
    fi
    
    echo "$filename"
}

# * Generate YAML frontmatter for Obsidian compatibility
# ? Includes metadata for better organization and tracking
generate_frontmatter() {
    local title="$1"
    local pattern="$2"
    local language="$3"
    local date
    date=$(get_current_date)
    
    cat << EOF
---
title: ${title%.md}
ai_agent: $DEFAULT_AGENT
ai_model: $DEFAULT_MODEL
pattern: $pattern
language: $language
creation_date: $date
tags:
  - ai/prompt
---

EOF
}

# * Execute fabric AI and generate content
# ! Main function that runs the AI processing and saves output
generate_ai_content() {
    local prompt_file="$1"
    local pattern="$2"
    local language="$3"
    local output_file="$4"
    local full_output_path="$OUTPUT_DIR/$output_file"
    
    print_info "Generating AI content..."
    print_info "Input: $(basename "$prompt_file")"
    print_info "Pattern: $pattern"
    print_info "Language: $language"
    print_info "Output: $output_file"
    
    # ! Note: This uses the 'fabric-ai' binary directly for script compatibility
    # ? Your aliases from .fabric.zsh work in interactive shell sessions
    
    # * Generate frontmatter
    local frontmatter
    frontmatter=$(generate_frontmatter "$output_file" "$pattern" "$language")
    
    # * Execute fabric-ai command and capture output
    local ai_content
    if ai_content=$(fabric-ai --pattern "$pattern" --language="$language" < "$prompt_file" 2>&1); then
        # * Combine frontmatter and AI content
        {
            echo "$frontmatter"
            echo "$ai_content"
        } > "$full_output_path"
        
        print_success "Content generated and saved to: $output_file"
        return 0
    else
        print_error "Failed to generate AI content:"
        print_error "$ai_content"
        return 1
    fi
}

# ================================================================
# 📋 MENU FUNCTIONS
# ================================================================

# * Post-save action menu
# ? Allows user to choose what to do with generated file
post_save_action() {
    local file_path="$1"
    
    print_info "File saved successfully. What would you like to do next?"
    
    local choice
    choice=$(gum choose "View in terminal" "Open in VS Code" "Open in Obsidian" "Return to Main Menu")
    
    case "$choice" in
        "View in terminal")
            local viewer
            viewer=$(get_text_viewer)
            print_info "Opening file with $viewer..."
            $viewer "$file_path"
            ;;
        "Open in VS Code")
            print_info "Opening file in VS Code..."
            code "$file_path" &
            ;;
        "Open in Obsidian")
            print_info "Opening file in Obsidian..."
            open_in_obsidian "$file_path"
            ;;
        "Return to Main Menu")
            return 0
            ;;
    esac
}

# * AI Helper main function - orchestrates the entire workflow
# ? This is the primary interactive function that guides users through the process
ai_helper() {
    print_info "Starting AI Helper..."
    
    # * Step 1: Select user prompt file
    print_info "Step 1: Select input file"
    local prompt_file
    if ! prompt_file=$(select_prompt_file); then
        return 1
    fi
    print_success "Selected: $(basename "$prompt_file")"
    
    # * Step 2: Select fabric pattern
    print_info "Step 2: Select fabric pattern"
    local pattern
    if ! pattern=$(select_fabric_pattern); then
        return 1
    fi
    print_success "Selected pattern: $pattern"
    
    # * Step 3: Get output language
    print_info "Step 3: Specify output language"
    local language
    language=$(get_output_language)
    print_success "Language: $language"
    
    # * Step 4: Get output filename
    print_info "Step 4: Choose output filename"
    local output_file
    if ! output_file=$(get_output_filename); then
        return 1
    fi
    print_success "Output file: $output_file"
    
    # * Step 5: Generate content
    print_info "Step 5: Generate AI content"
    if generate_ai_content "$prompt_file" "$pattern" "$language" "$output_file"; then
        # * Step 6: Post-save actions
        post_save_action "$OUTPUT_DIR/$output_file"
    else
        print_error "Failed to generate content. Please try again."
        return 1
    fi
}

# * File action menu for selected files
# ? Provides options to view, edit, or delete files
file_action_menu() {
    local file_path="$1"
    local file_type="$2"  # * "input" or "output"
    
    print_info "Selected: $(basename "$file_path")"
    
    local choice
    choice=$(gum choose "View in terminal" "Open in VS Code" "Open in Obsidian" "Remove file" "Return to Main Menu")
    
    case "$choice" in
        "View in terminal")
            local viewer
            viewer=$(get_text_viewer)
            print_info "Opening file with $viewer..."
            $viewer "$file_path"
            ;;
        "Open in VS Code")
            print_info "Opening file in VS Code..."
            code "$file_path" &
            ;;
        "Open in Obsidian")
            print_info "Opening file in Obsidian..."
            open_in_obsidian "$file_path"
            ;;
        "Remove file")
            print_warning "You are about to delete: $(basename "$file_path")"
            if gum confirm "Are you sure you want to delete this file?"; then
                if rm "$file_path"; then
                    print_success "File deleted successfully."
                else
                    print_error "Failed to delete file."
                fi
            else
                print_info "File deletion cancelled."
            fi
            ;;
        "Return to Main Menu")
            return 0
            ;;
    esac
}

# * List input files for browsing and management
# ? Shows all .md files in the input directory
list_inputs() {
    print_info "Listing input files from: $INPUT_DIR"
    
    local files
    files=$(find "$INPUT_DIR" -name "*.md" -type f 2>/dev/null | sort)
    
    if [[ -z "$files" ]]; then
        print_warning "No .md files found in input directory."
        gum input --placeholder "Press Enter to continue..."
        return 0
    fi
    
    # * Use fzf to select file
    local selected_file
    selected_file=$(echo "$files" | fzf --prompt="Select input file: " --height=10 --border)
    
    if [[ -n "$selected_file" ]]; then
        file_action_menu "$selected_file" "input"
    fi
}

# * List output files for browsing and management
# ? Shows generated files in the output directory (root level only)
list_outputs() {
    print_info "Listing output files from: $OUTPUT_DIR (root only)"
    
    local files
    files=$(find "$OUTPUT_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort)
    
    if [[ -z "$files" ]]; then
        print_warning "No .md files found in output directory root."
        gum input --placeholder "Press Enter to continue..."
        return 0
    fi
    
    # * Use fzf to select file
    local selected_file
    selected_file=$(echo "$files" | fzf --prompt="Select output file: " --height=10 --border)
    
    if [[ -n "$selected_file" ]]; then
        file_action_menu "$selected_file" "output"
    fi
}

# * Main menu loop - the heart of the interactive interface
# ? Provides navigation between all major functions
main_menu() {
    while true; do
        clear
        print_header
        
        print_info "Input Directory: $INPUT_DIR"
        print_info "Output Directory: $OUTPUT_DIR"
        echo
        
        local choice
        choice=$(gum choose "AI Helper" "List Inputs" "List Outputs" "Exit")
        
        case "$choice" in
            "AI Helper")
                ai_helper
                ;;
            "List Inputs")
                list_inputs
                ;;
            "List Outputs")
                list_outputs
                ;;
            "Exit")
                print_success "Thank you for using Fabric AI Helper!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                ;;
        esac
        
        # * Pause before returning to menu (unless exiting)
        if [[ "$choice" != "Exit" ]]; then
            echo
            gum input --placeholder "Press Enter to return to main menu..."
        fi
    done
}

# ================================================================
# 🚀 MAIN EXECUTION
# ================================================================

main() {
    # * Check dependencies
    check_dependencies
    
    # * Ensure directories exist
    ensure_directories
    
    # * Start main menu
    main_menu
}

# * Execute main function if script is run directly
# ? This allows the script to be sourced without running automatically
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
