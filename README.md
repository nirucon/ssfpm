# ssfpm - Shit Simple File and Package Manager

Made in bash... started as a fork of fzfm.
This project is just for fun and when I have time for it.

## WORK IN PROGRESS !!!

### Key Features of SSFPM (Shit Simple File and Package Manager) TUI

1. **File and Directory Management**:
    - **Browse Files and Directories**: Use `lsd` for listing with icons, and `fzf` for interactive selection.
    - **Create Directories**: Easily create new directories.
    - **Create Files**: Create multiple files at once.
    - **Copy Files/Directories**: Copy selected files/directories to a temporary directory.
    - **Move Files/Directories**: Move files/directories to a temporary directory or to a new location.
    - **Delete Files/Directories**: Delete selected files/directories using `trash-cli`.

2. **Package Management**:
    - **Search Packages**: Search for packages using the system's package manager (`pacman`, `apt`, `dnf`, `xbps`).
    - **AUR Support**: For Arch-based distributions, search for AUR packages using helpers like `yay`, `paru`, and `trizen`.
    - **Install Packages**: Prompt to install selected packages directly from the TUI.

3. **Text Editor Configuration**:
    - **Select Preferred Text Editor**: Choose between `nano`, `vim`, and `nvim` as the default text editor.
    - **Persist Configuration**: Save the preferred text editor in a configuration file (`~/.config/ssfpm/ssfpm.conf`) for future sessions.

4. **User Interface**:
    - **Interactive Selection**: Use `fzf` for interactive file and package selection.
    - **Preview Pane**: Display file previews with syntax highlighting for text files (`bat`) and image previews (`chafa`).
    - **Customizable UI**: Easily toggle between different functionalities and view detailed information within the terminal.

5. **Dependency Management**:
    - **Automatic Dependency Check**: Check for necessary dependencies on startup.
    - **Install Missing Dependencies**: Automatically install missing dependencies based on the detected Linux distribution.

6. **Compatibility**:
    - **Supports Multiple Distributions**: Compatible with Arch, Manjaro, EndeavourOS, ArcoLinux, Garuda, Debian, Ubuntu, Linux Mint, Fedora, and Void Linux.
    - **Wide Package Manager Support**: Works with various package managers including `pacman`, `apt`, `dnf`, and `xbps`.

### Summary:
SSFPM provides a simple, efficient, and interactive terminal user interface for managing files, directories, and packages on various Linux distributions. It integrates powerful tools and supports multiple package managers and text editors, offering a customizable and user-friendly experience.
