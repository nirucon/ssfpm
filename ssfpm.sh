#!/usr/bin/env bash

# ssfpm - Shit Simple File and Package Manager
# By Nicklas Rudolfsson
# Fork of fzfm and made just for fun when I have time for it.
# ------> WORK IN PROGRESS - SOME THINGS MIGHT WORK AND SOME NOT!!! <------

# Dependencies:
# - lsd
# - fzf
# - bat
# - chafa
# - trash-cli
# - nano or vim or nvim
# - gimp
# - sxiv
# - mpv
# - libreoffice
# - zathura

# Define the temporary directory and config directory
TEMP_DIR="/tmp/ssfpm"
CONFIG_DIR="$HOME/.config/ssfpm"
CONFIG_FILE="$CONFIG_DIR/ssfpm.conf"

# Ensure the temporary and config directories exist
mkdir -p "$TEMP_DIR"
mkdir -p "$CONFIG_DIR"

# Load or set default text editor
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    TEXT_EDITOR="nano"
fi

# Function to check for dependencies and install missing ones
check_dependencies() {
    local dependencies=("lsd" "fzf" "bat" "chafa" "trash-cli" "nano" "vim" "nvim" "gimp" "sxiv" "mpv" "libreoffice" "zathura")
    local missing_deps=()

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -eq 0 ]; then
        return
    fi

    echo "ssfpm needs some dependencies for all features to work. You are missing: ${missing_deps[*]}"
    read -rp "Do you want to install them now? (Y/n): " install_choice
    install_choice=${install_choice:-Y}
    if [[ "$install_choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        local os_release_file="/etc/os-release"
        if [[ -f "$os_release_file" ]]; then
            source "$os_release_file"
        else
            echo "Cannot determine the Linux distribution. Please install the missing dependencies manually."
            exit 1
        fi

        case "$ID" in
            arch|manjaro|endeavouros|arcolinux|garuda)
                sudo pacman -Sy --noconfirm "${missing_deps[@]}"
                ;;
            debian|ubuntu|linuxmint)
                sudo apt update && sudo apt install -y "${missing_deps[@]}"
                ;;
            fedora)
                sudo dnf install -y "${missing_deps[@]}"
                ;;
            void)
                sudo xbps-install -Sy "${missing_deps[@]}"
                ;;
            *)
                echo "Unsupported Linux distribution. Please install the missing dependencies manually."
                exit 1
                ;;
        esac
    else
        exit 1
    fi
}

# Function to search and install packages
sspm() {
    read -rp "Enter package name to search: " package_name
    case "$ID" in
        arch|manjaro|endeavouros|arcolinux|garuda)
            search_result=$(pacman -Ss "$package_name")
            installed_packages=$(pacman -Qs "$package_name")
            ;;
        debian|ubuntu|linuxmint)
            search_result=$(apt search "$package_name")
            installed_packages=$(dpkg -l | grep "$package_name")
            ;;
        fedora)
            search_result=$(dnf search "$package_name")
            installed_packages=$(dnf list installed | grep "$package_name")
            ;;
        void)
            search_result=$(xbps-query -Rs "$package_name")
            installed_packages=$(xbps-query -l | grep "$package_name")
            ;;
        *)
            echo "Unsupported Linux distribution. Cannot search for packages."
            return
            ;;
    esac

    echo "Installed Packages:"
    echo "$installed_packages"
    echo
    echo "Available Packages:"
    echo "$search_result"
    
    # AUR search for Arch-based distros
    if [[ "$ID" == "arch" || "$ID" == "manjaro" || "$ID" == "endeavouros" || "$ID" == "arcolinux" || "$ID" == "garuda" ]]; then
        aur_helpers=("yay" "paru" "trizen")
        for helper in "${aur_helpers[@]}"; do
            if command -v "$helper" &> /dev/null; then
                aur_result=$("$helper" -Ss "$package_name")
                echo
                echo "AUR Packages:"
                echo "$aur_result"
                break
            fi
        done
    fi
    
    read -rp "Do you want to install any of these packages? Enter package name(s) separated by spaces or press enter to skip: " install_packages
    if [[ -n "$install_packages" ]]; then
        case "$ID" in
            arch|manjaro|endeavouros|arcolinux|garuda)
                if [[ -n "$aur_result" ]]; then
                    aur_install=$("$helper" -S --noconfirm $install_packages)
                    echo "$aur_install"
                else
                    sudo pacman -S --noconfirm $install_packages
                fi
                ;;
            debian|ubuntu|linuxmint)
                sudo apt install -y $install_packages
                ;;
            fedora)
                sudo dnf install -y $install_packages
                ;;
            void)
                sudo xbps-install -Sy $install_packages
                ;;
            *)
                echo "Unsupported Linux distribution. Cannot install packages."
                return
                ;;
        esac
    fi
}

# Function to handle file/directory selection and operations
ssfpm() {
    while true; do
        selection="$(lsd -a -1 | fzf \
            --bind 'left:pos(2)+accept' \
            --bind 'right:accept' \
            --bind 'shift-up:preview-up' \
            --bind 'shift-down:preview-down' \
            --bind 'ctrl-d:execute(create_dir)+reload(lsd -a -1)' \
            --bind 'ctrl-f:execute(create_file)+reload(lsd -a -1)' \
            --bind 'ctrl-t:execute(trash {+})+reload(lsd -a -1)' \
            --bind 'ctrl-c:execute(copy_function {} $TEMP_DIR/$(basename {}).copy)' \
            --bind 'ctrl-m:execute(move_function {} $TEMP_DIR/$(basename {}).copy)+reload(lsd -a -1)' \
            --bind 'ctrl-g:execute(move_function $TEMP_DIR/* . && rm -rf $TEMP_DIR/*)+reload(lsd -a -1)' \
            --bind 'ctrl-p:execute(sspm)+reload(lsd -a -1)' \
            --bind 'esc:execute(rm -rf $TEMP_DIR/*)+abort' \
            --bind 'space:toggle' \
            --color=fg:#d0d0d0,fg+:#d0d0d0,bg+:#262626 \
            --color=hl:#5f87af,hl+:#487caf,info:#afaf87,marker:#274a37 \
            --color=pointer:#a62b2b,spinner:#af5fff,prompt:#876253,header:#87afaf \
            --height 95% \
            --pointer "" \
            --reverse \
            --multi \
            --info inline-right \
            --prompt "Search files: " \
            --header "SSFPM - Shit Simple File and Package Manager | Search files (left) | Search packages (ctrl+p)" \
            --header-first \
            --border "bold" \
            --border-label "$(pwd)/" \
            --preview-window=right:65% \
            --preview 'sel=$(echo {} | cut -d " " -f 2); cd_pre="$(echo $(pwd)/$(echo {}))";
                    echo "Folder: " $cd_pre;
                    lsd -a --icon=always --color=always "${cd_pre}";
                    cur_file="$(file $(echo $sel) | grep [Tt]ext | wc -l)";
                    if [[ "${cur_file}" -eq 1 ]]; then
                        bat --style=numbers --theme=ansi --color=always $sel 2>/dev/null
                    else
                        chafa -c full --color-space rgb --dither none -p on -w 9 2>/dev/null {}
                    fi')"
        if [[ "$selection" == "ssfpm-options" ]]; then
            ssfpm_options
        elif [[ -d ${selection} ]]; then
            cd "${selection}" || return
        elif [[ -f "${selection}" ]]; then
            file_type=$(file -b --mime-type "${selection}" | cut -d'/' -f1)
            case $file_type in
                "text"|"inode")
                    $TEXT_EDITOR "${selection}"
                    ;;
                "image")
                    for fType in ${selection}; do
                        if [[ "${fType}" == *.xcf ]]; then
                            gimp 2>/dev/null "${selection}"
                        else
                            sxiv "${selection}"
                        fi
                    done
                    ;;
                "video"|"audio")
                    mpv "${selection}" > /dev/null
                    ;;
                "application")
                    for fType in ${selection}; do
                        if [[ "${fType}" == *.docx ]] || [[ "${fType}" == *.odt ]]; then
                            libreoffice "${selection}" > /dev/null
                        elif [[ "${fType}" == *.pdf ]]; then
                            zathura 2>/dev/null "${selection}"
                        fi
                    done
                    ;;
                "music")
                    mpv "${selection}" > /dev/null
                    ;;
            esac
        else
            break
        fi
    done
}

# Function to create a new directory
create_dir() {
    read -rp "Enter Directory Name: " new_dir_name
    mkdir -p "$(pwd)/${new_dir_name}"
}

# Function to create new files
create_file() {
    read -rp "Enter file names separated by spaces: " filenames
    for filename in $filenames; do
        touch "$(pwd)/$filename"
    done
}

# Function to copy files/directories
copy_function() {
    src=$1
    dst=$2
    cp -R "$src" "$dst"
}

# Function to move files/directories
move_function() {
    src=$1
    dst=$2
    mv -n "$src" "$dst"
}

# Function to handle ssfpm options
ssfpm_options() {
    selected_editor=$(printf "nano\nvim\nnvim" | fzf --prompt="Select preferred text editor: ")
    if [[ -n "$selected_editor" ]]; then
        TEXT_EDITOR="$selected_editor"
        echo "TEXT_EDITOR=$TEXT_EDITOR" > "$CONFIG_FILE"
        echo "Default text editor set to $TEXT_EDITOR. This can be changed later by searching for 'ssfpm-options'."
        echo "Configuration file is stored at $CONFIG_FILE."
    fi
    ssfpm
}

# Check dependencies before starting the file manager
check_dependencies

# Start the file manager
clear
ssfpm
