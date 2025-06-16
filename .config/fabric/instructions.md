As a highly skilled software engineer with extensive experience in Linux and shell scripting, your task is to design and implement a robust shell script. This script will act as a command-line interface for interacting with `fabric-ai` patterns, generating content, and managing files within an Obsidian vault structure.

The user is comfortable with programming but has limited experience with shell scripting. Therefore, your solution must adhere to shell scripting best practices, be well-documented, and prioritize user experience and robustness.

**Overall Goal:** Create an interactive shell script that simplifies the use of `fabric-ai` by providing a menu-driven interface for generating AI content and managing related input/output files within a specified Obsidian directory structure.

Fabric AI documentation: #fetch https://github.com/danielmiessler/fabric

---

### **Strategy First: Plan the Script Architecture**

Before writing any code, outline your strategy for building this script. Think about modularity, error handling, user interaction, and tool integration.

**Your strategy should cover:**

1.  **Script Structure:** How will the main menu loop, functions for each option, and global variables be organized?
2.  **Tool Selection:** Justify the use of `gum`, `fzf`, and any other command-line tools you deem necessary for interactive elements (e.g., menus, file selection, input prompts).
3.  **File Path Management:** How will you handle the base directories for inputs and outputs, ensuring they are configurable and robust?
4.  **Error Handling:** What mechanisms will be in place to handle missing files, invalid user input, or failures during `fabric-ai` execution?
5.  **User Experience:** How will you ensure the script is intuitive and provides clear feedback, especially for someone new to shell scripting?
6.  **Security/Safety:** Consider any implications of file operations (delete, open) and how to mitigate risks (e.g., confirmation prompts).

---

### **Implement the Shell Script**

Based on your strategy, write the complete shell script. Ensure it is executable and follows best practices.

**Key Requirements for the Script:**

1.  **Shebang and Robustness:** Start with `#!/bin/bash` and include `set -euo pipefail` for immediate error handling.
2.  **Clear Comments:** Document every function, complex logic block, and critical variable with clear, concise comments.
3.  **User-Friendly Messages:** Provide informative messages to the user for selections, actions, and errors.

**Main Menu Options:**

The script should present a persistent main menu with the following options:

*   **AI Helper**
*   **List Inputs**
*   **List Outputs**
*   **Exit**

**Detailed Functionality for Each Option:**

#### **1. AI Helper**

*   **Select User Prompt File:**
    *   List all `.md` files within the input directory: `/home/marcus/notes/Vortex/99-Setup/Al Chat History/_input`.
    *   Allow the user to interactively select a file using `fzf`.
    *   Validate that the selected file exists and is readable.
*   **Select `fabric-ai` Pattern:**
    *   Provide a list of available `fabric-ai` patterns. Assume you can get this list by executing `fabric --list-patterns` (or if that's not available, provide a hardcoded list of common patterns, e.g., "code-generator", "summarize", "brainstorm", "creative-writing").
    *   Allow the user to interactively select a pattern, with typing to search, using `fzf`.
    *   Validate that a pattern is selected.
*   **Output Language:**
    *   Prompt the user to enter the desired output language (e.g., "en-US", "pt-BR"). Provide a default or common suggestions if possible.
*   **Choose Destination File Name:**
    *   Prompt the user to enter a desired filename for the output (`.md` extension will be added automatically if not provided).
    *   The file should be saved in the output directory: `/home/marcus/notes/Vortex/99-Setup/Al Chat History/`.
    *   Ensure the filename is valid and does not overwrite an existing file without confirmation.
*   **Generate Content and Save:**
    *   Execute `fabric-ai` using the selected user prompt file, pattern, and output language.
    *   **Crucially, prepend the generated content with the following YAML frontmatter:**
        ```yaml
        ---
		title: <Chosen Filename>
		ai_agent: <Default Agent>
		ai_model: <Default Model>
		pattern: <Chosen Pattern>
		language: <Chosen Language>
		creation_date:
		tags:
		  - ai/prompt
        ---
        ```
        *Replace `<Chosen Filename>`, `<Chosen Pattern>`, and `<Chosen Language>`, etc,  with the actual values.*
    *   Save the combined frontmatter and generated content to the chosen `.md` file in the output directory.
*   **Post-Save Action:**
    *   After saving, present a menu (`gum choose`) asking the user if they want to:
        *   Open the file in the terminal (using `less` or `cat`).
        *   Open the file with `code` (VS Code).
        *   Open the file with Obsidian (using `xdg-open` or a direct Obsidian command if known, otherwise `xdg-open` is preferred for cross-desktop compatibility).
        *   Return to the Main Menu.

#### **2. List Inputs**

*   List all files in the input directory: `/home/marcus/notes/Vortex/99-Setup/Al Chat History/_input`.
*   Allow the user to interactively select a file using `fzf`.
*   Upon selection, present a menu (`gum choose`) with options:
    *   Open the file (using `less`, `code`, or `xdg-open`).
    *   Remove the file (with a confirmation prompt using `gum confirm`).
    *   Return to the Main Menu.

#### **3. List Outputs**

*   List all files in the output directory: `/home/marcus/notes/Vortex/99-Setup/Al Chat History/`.
*   Allow the user to interactively select a file using `fzf`.
*   Upon selection, present a menu (`gum choose`) with options:
    *   Open the file (using `less`, `code`, or `xdg-open`).
    *   Remove the file (with a confirmation prompt using `gum confirm`).
    *   Return to the Main Menu.

#### **4. Exit**

*   Terminate the script gracefully.

---

### **Testing Plan**

Describe a basic testing strategy for the script. How would you verify its functionality without "messing up the current environment"?

**Your testing plan should include:**

*   **Setup:** How would you create a temporary environment for testing (e.g., mock directories, dummy files)?
*   **Test Cases:** List specific scenarios you would test for each main menu option (AI Helper, List Inputs, List Outputs).
*   **Validation:** How would you verify the correctness of file creation, content, and deletion?
*   **Error Condition Testing:** How would you test scenarios like missing input files, invalid user choices, or `fabric-ai` command failures?

---