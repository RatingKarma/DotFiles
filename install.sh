#!/bin/bash

# User `.config` directory absolute path
TARGET_CONFIG_DIR="${HOME}/.config"

# Copy `zsh` and `zim` config files
function copy_zsh_config(){
    if [[ -d "${HOME}/.zim" ]]; then
        rm -rf "${HOME}/.zim"
    fi

    # Install zim
    echo "Install zim..."
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

    # Copy config files
    echo "Copy zsh config files"
    cp zsh/.zshrc "${HOME}"
    cp zsh/.zimrc "${HOME}"

    # Restart zsh
    exec zsh
    echo "Success: Copied zsh config files to ${HOME}/.zshrc"
}

# Check `.config` path
if [ ! -d "${TARGET_CONFIG_DIR}" ]; then
    mkdir -p "${TARGET_CONFIG_DIR}"
fi

# Array to store current directory's subdirectories
CURRENT_DIRECTORIES=()

# Add all subdirectories into array
for directory in */ .*/; do
    # Skip current (./) and parent (../) directory references
    if [[ -d "$directory" ]] && [[ "$directory" != "./" ]] && [[ "$directory" != "../" ]]; then
        # Remove trailing slash and add to array
        CURRENT_DIRECTORIES+=("${directory%/}")
    fi  
done

# Process each user-input arguments
for user_input in "$@"; do
    if [[ $user_input == "zsh" ]]; then
        copy_zsh_config
        chsh -s /bin/zsh    # Change default shell to `zsh`
        continue
    fi

    directory_found=false
    
    # Check if user input matches an existing directory
    for existing_directory in "${CURRENT_DIRECTORIES[@]}"; do
        if [[ "$user_input" == "$existing_directory" ]]; then
            directory_found=true
            break
        fi
    done

    if [[ "$directory_found" == true ]]; then
        # Copy directory to target location
        if cp -r "${user_input}" "${TARGET_CONFIG_DIR}/${user_input}"; then
            echo "Success: Copied ${user_input} to ${TARGET_CONFIG_DIR}/${user_input}"
        else
            echo "Error: Failed to copy directory ${user_input}" >&2
        fi
    else
        echo "Error: No such config directory: ${user_input}" >&2
    fi
done
