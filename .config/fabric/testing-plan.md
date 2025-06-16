# Testing Plan for Fabric AI Helper Script

## Overview
This document outlines the testing strategy for the `fabric-ai-helper.sh` script to ensure it functions correctly without disrupting the current environment.

## Test Environment Setup

### 1. Create Temporary Test Environment
```bash
# Create temporary test directories
mkdir -p /tmp/fabric-test/input
mkdir -p /tmp/fabric-test/output

# Create test input files
echo "# Test Prompt 1" > /tmp/fabric-test/input/test1.md
echo "This is a test prompt for AI processing." >> /tmp/fabric-test/input/test1.md

echo "# Test Prompt 2" > /tmp/fabric-test/input/test2.md
echo "Another test prompt with different content." >> /tmp/fabric-test/input/test2.md

# Create a test version of the script with modified paths
cp /home/marcus/.config/fabric/fabric-ai-helper.sh /tmp/fabric-test/test-script.sh
```

### 2. Modify Script for Testing
Update the test script to use temporary directories:
```bash
sed -i 's|INPUT_DIR="/home/marcus/notes/Vortex/99-Setup/Al Chat History/_input"|INPUT_DIR="/tmp/fabric-test/input"|' /tmp/fabric-test/test-script.sh
sed -i 's|OUTPUT_DIR="/home/marcus/notes/Vortex/99-Setup/Al Chat History"|OUTPUT_DIR="/tmp/fabric-test/output"|' /tmp/fabric-test/test-script.sh
```

## Test Cases

### 1. Dependency Check Tests
- **Test 1.1**: Run script without required dependencies
  - Expected: Script should detect missing dependencies and exit gracefully
  - Command: `./test-script.sh` (after temporarily renaming required commands)

- **Test 1.2**: Run script with all dependencies available
  - Expected: Script should proceed to main menu
  - Command: `./test-script.sh`

### 2. Directory Management Tests
- **Test 2.1**: Run script with non-existent directories
  - Expected: Script should prompt to create directories
  - Setup: Remove test directories before running

- **Test 2.2**: Run script with existing directories
  - Expected: Script should proceed normally
  - Setup: Ensure test directories exist

### 3. AI Helper Function Tests
- **Test 3.1**: Select input file
  - Expected: fzf should display available .md files
  - Validation: User can select a file and proceed

- **Test 3.2**: Select fabric pattern
  - Expected: fzf should display available patterns
  - Validation: User can select a pattern and proceed

- **Test 3.3**: Input validation for output language
  - Expected: Accept valid language codes, use default for empty input
  - Test inputs: "en-US", "pt-BR", "" (empty)

- **Test 3.4**: Filename validation
  - Expected: Validate and sanitize filenames, add .md extension
  - Test inputs: "test", "test.md", "test file", "test/file"

- **Test 3.5**: File overwrite protection
  - Expected: Prompt for confirmation when file exists
  - Setup: Create existing file in output directory

- **Test 3.6**: Complete AI content generation flow
  - Expected: Generate content with proper frontmatter
  - Validation: Check output file format and content

### 4. List Inputs Function Tests
- **Test 4.1**: List files when input directory has files
  - Expected: fzf displays all .md files
  - Setup: Ensure test input files exist

- **Test 4.2**: List files when input directory is empty
  - Expected: Display appropriate message
  - Setup: Remove all files from input directory

- **Test 4.3**: File action menu functionality
  - Expected: All menu options work correctly
  - Test: View, edit, delete operations

### 5. List Outputs Function Tests
- **Test 5.1**: List files when output directory has files
  - Expected: fzf displays all .md files
  - Setup: Create test output files

- **Test 5.2**: List files when output directory is empty
  - Expected: Display appropriate message
  - Setup: Ensure output directory is empty

- **Test 5.3**: File action menu functionality
  - Expected: All menu options work correctly
  - Test: View, edit, delete operations

### 6. Error Condition Tests
- **Test 6.1**: Missing input files
  - Expected: Graceful error handling with informative messages
  - Setup: Remove all input files

- **Test 6.2**: Fabric command failure
  - Expected: Error message and graceful fallback
  - Setup: Mock fabric command to return error

- **Test 6.3**: Permission issues
  - Expected: Clear error messages for permission problems
  - Setup: Remove write permissions from output directory

- **Test 6.4**: Invalid user input
  - Expected: Input validation and re-prompting
  - Test: Empty strings, special characters, invalid filenames

### 7. Integration Tests
- **Test 7.1**: End-to-end workflow
  - Run complete AI Helper workflow from start to finish
  - Validate all generated files and frontmatter

- **Test 7.2**: Multiple file operations
  - Test creating, viewing, and deleting multiple files
  - Validate file system state

- **Test 7.3**: Navigation between menu options
  - Test all menu transitions and return paths
  - Validate user can navigate freely

## Validation Methods

### 1. File Content Validation
```bash
# Check frontmatter format
head -n 10 /tmp/fabric-test/output/test-file.md | grep -E "^---$|^title:|^ai_agent:|^pattern:|^language:|^creation_date:|^tags:"

# Validate YAML frontmatter
python3 -c "
import yaml
with open('/tmp/fabric-test/output/test-file.md', 'r') as f:
    content = f.read()
    if content.startswith('---'):
        frontmatter = content.split('---')[1]
        yaml.safe_load(frontmatter)
        print('Valid YAML frontmatter')
"
```

### 2. File System State Validation
```bash
# Check file creation
ls -la /tmp/fabric-test/output/

# Check file permissions
stat /tmp/fabric-test/output/test-file.md

# Validate directory structure
tree /tmp/fabric-test/
```

### 3. Dependency Validation
```bash
# Verify required commands
for cmd in gum fzf fabric; do
    if command -v $cmd &> /dev/null; then
        echo "$cmd: Available"
    else
        echo "$cmd: Missing"
    fi
done
```

## Cleanup
```bash
# Remove test environment
rm -rf /tmp/fabric-test/

# Restore original script if modified
# (No cleanup needed as original script was not modified)
```

## Success Criteria
1. All menu options function correctly
2. File operations (create, read, delete) work as expected
3. Input validation prevents invalid operations
4. Error conditions are handled gracefully
5. Generated files have correct format and frontmatter
6. No data loss or corruption in production directories
7. Script exits cleanly in all scenarios

## Risk Mitigation
- Use temporary directories for all tests
- Never modify production data during testing
- Backup any existing configurations before testing
- Test with isolated fabric patterns if available
- Use mock data for all input files

## Automated Testing Script
```bash
#!/bin/bash
# automated-test.sh - Run all tests automatically

set -euo pipefail

# Setup test environment
./setup-test-env.sh

# Run individual test suites
./test-dependencies.sh
./test-file-operations.sh
./test-menu-functions.sh
./test-error-conditions.sh

# Cleanup
./cleanup-test-env.sh

echo "All tests completed successfully!"
```
