# Gemini Project: Dotfiles

## Project Overview

This is a "dotfiles" project designed to provide a consistent and customizable development environment. It's a collection of scripts, configuration files, and settings for managing a user's shell, command-line tools, and macOS system preferences. The project is built around a modular "topic" system, where each topic represents a specific tool or technology (e.g., Git, Node.js, Homebrew). A central `dot` command-line utility provides a simple interface for managing the entire setup.

The primary technologies used are shell scripting (Bash and Zsh), with configurations for a wide range of developer tools. The project uses Prezto as a framework for Zsh configuration.

## Building and Running

This project is not "built" in the traditional sense of compiling code. Instead, it is "installed" by creating symbolic links from the project's files to the user's home directory.

**Key Commands:**

*   **Bootstrap/Installation:** The main setup is performed by the `bootstrap` script. This script symlinks the necessary configuration files into the user's home directory.
    ```bash
    src/script/bootstrap
    ```

*   **Main `dot` command:** The `dot` command is the primary interface for managing the dotfiles environment. It is located in `src/bin/dot`.
    ```bash
    # See all available commands
    dot help

    # Install a specific topic (e.g., node)
    dot install node

    # Update all packages and package managers
    dot update
    ```

*   **Interactive Installation:** To run all installers for all topics interactively:
    ```bash
    src/script/install
    ```

*   **Testing:** The project has a test suite that can be run with the following command:
    ```bash
    dot test
    ```

## Development Conventions

*   **Topical Structure:** The project is organized into "topics," with each topic residing in its own directory under `src/topics/`. Each topic can contain:
    *   `aliases.sh`: Shell aliases.
    *   `path.zsh`: Shell path configuration.
    *   `completion.zsh`: Shell completion scripts.
    *   `install.sh`: An installation script for the topic.
    *   `*.symlink`: Files that will be symlinked to the user's home directory.

*   **Symlinking:** Files with the `.symlink` extension are automatically symlinked to the user's home directory by the `bootstrap` script. For example, `src/topics/git/gitconfig.symlink` is linked to `~/.gitconfig`.

*   **Scripts:**
    *   `src/script/`: Contains the main scripts for bootstrapping, installation, and updates.
    *   `src/bin/`: Contains executable scripts that are added to the user's `$PATH`.
    *   `src/functions/`: Contains shell functions that are loaded into the environment.

*   **Zsh and Prezto:** The project uses Zsh as the primary shell and the Prezto framework for configuration. The main Prezto configuration file is `src/topics/prezto/zpreztorc.symlink`, which defines the modules to be loaded.

*   **Homebrew:** The `src/topics/homebrew/Brewfile.symlink` file defines the list of packages to be installed via Homebrew.

*   **macOS Defaults:** The project can configure macOS system settings using the `macos-defaults` tool. The configuration is located in `src/topics/macos/defaults/`.
