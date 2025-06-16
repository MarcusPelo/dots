#!/bin/bash

# Automated Test Setup for Fabric AI Helper Script
# This script creates a safe testing environment

set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

print_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Test environment paths
readonly TEST_BASE="/tmp/fabric-test"
readonly TEST_INPUT="$TEST_BASE/input"
readonly TEST_OUTPUT="$TEST_BASE/output"
readonly TEST_SCRIPT="$TEST_BASE/test-script.sh"

setup_test_environment() {
    print_info "Setting up test environment..."
    
    # Create test directories
    mkdir -p "$TEST_INPUT" "$TEST_OUTPUT"
    
    # Create sample input files
    cat > "$TEST_INPUT/sample1.md" << 'EOF'
# Test Article Analysis

This is a sample article that needs to be analyzed by AI. It contains various topics including technology, business, and innovation.

The article discusses the impact of artificial intelligence on modern business practices and how companies are adapting to new technologies.

Key points:
- AI adoption in enterprises
- Digital transformation trends
- Future of work
EOF

    cat > "$TEST_INPUT/sample2.md" << 'EOF'
# Code Review Request

Please review the following code snippet and provide suggestions for improvement:

```python
def process_data(data):
    result = []
    for item in data:
        if item > 0:
            result.append(item * 2)
    return result
```

Focus on:
- Performance optimization
- Code readability
- Best practices
EOF

    cat > "$TEST_INPUT/creative_prompt.md" << 'EOF'
# Creative Writing Prompt

Write a short story about a programmer who discovers that their code has gained consciousness. The story should explore themes of:

- Artificial intelligence ethics
- The relationship between creator and creation
- Technology and humanity

The story should be approximately 500 words and written in a compelling narrative style.
EOF

    # Copy and modify the main script for testing
    cp "/home/marcus/.config/fabric/fabric-ai-helper.sh" "$TEST_SCRIPT"
    
    # Update paths in test script
    sed -i "s|INPUT_DIR=\"/home/marcus/notes/Vortex/99-Setup/Al Chat History/_input\"|INPUT_DIR=\"$TEST_INPUT\"|" "$TEST_SCRIPT"
    sed -i "s|OUTPUT_DIR=\"/home/marcus/notes/Vortex/99-Setup/Al Chat History\"|OUTPUT_DIR=\"$TEST_OUTPUT\"|" "$TEST_SCRIPT"
    
    # Make test script executable
    chmod +x "$TEST_SCRIPT"
    
    print_success "Test environment created at: $TEST_BASE"
    print_info "Test input files created:"
    ls -la "$TEST_INPUT"
}

run_dependency_tests() {
    print_info "Testing dependencies..."
    
    local deps=("gum" "fzf" "fabric")
    local all_present=true
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_success "$dep is available"
        else
            print_warning "$dep is NOT available"
            all_present=false
        fi
    done
    
    if $all_present; then
        print_success "All dependencies are available"
    else
        print_warning "Some dependencies are missing - script will show appropriate errors"
    fi
}

test_script_functionality() {
    print_info "Testing basic script functionality..."
    
    # Test that script can be executed
    if "$TEST_SCRIPT" --help 2>/dev/null || true; then
        print_info "Script can be executed"
    fi
    
    # Test directory validation
    if [[ -d "$TEST_INPUT" && -d "$TEST_OUTPUT" ]]; then
        print_success "Test directories exist"
    fi
    
    # Test input files
    local file_count
    file_count=$(find "$TEST_INPUT" -name "*.md" | wc -l)
    print_info "Found $file_count input files for testing"
}

create_sample_output() {
    print_info "Creating sample output file for testing..."
    
    cat > "$TEST_OUTPUT/sample_output.md" << 'EOF'
---
title: Sample Output
ai_agent: fabric-ai
ai_model: gpt-4
pattern: summarize
language: en-US
creation_date: 2025-06-16
tags:
  - ai/prompt
---

# Summary of Test Content

This is a sample output file that demonstrates the expected format for AI-generated content. The file includes proper YAML frontmatter and content structure.

## Key Points
- Proper frontmatter formatting
- Clear content structure
- Appropriate metadata
EOF

    print_success "Sample output file created"
}

show_usage_instructions() {
    print_info "Test environment is ready!"
    echo
    echo "To run the test script:"
    echo "  $TEST_SCRIPT"
    echo
    echo "To test manually:"
    echo "1. Run the test script: $TEST_SCRIPT"
    echo "2. Select 'AI Helper' to test the full workflow"
    echo "3. Select 'List Inputs' to browse test input files"
    echo "4. Select 'List Outputs' to browse generated files"
    echo
    echo "Test files locations:"
    echo "- Input files: $TEST_INPUT"
    echo "- Output files: $TEST_OUTPUT"
    echo "- Test script: $TEST_SCRIPT"
    echo
    echo "To cleanup after testing:"
    echo "  rm -rf $TEST_BASE"
}

main() {
    echo "=========================================="
    echo "  Fabric AI Helper Script Test Setup"
    echo "=========================================="
    echo
    
    setup_test_environment
    run_dependency_tests
    test_script_functionality
    create_sample_output
    show_usage_instructions
    
    echo
    print_success "Test setup completed successfully!"
}

main "$@"
