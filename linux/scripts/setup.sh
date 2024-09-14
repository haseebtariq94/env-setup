#!/bin/bash

set -e

error() {
    echo -e "\033[0;31m$1\033[0m"
    exit 1
}

warning() {
    echo -e "\033[0;33m$1\033[0m"
}

# Determine the directory with Linux settings
LINUX_DIR=$(dirname "$(realpath "$(dirname "$0")")")
if [ -z "$LINUX_DIR" ]; then
    error "Failed to determine the parent directory."
fi

# Get the names of terminal and shell
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ||
   (! pgrep -x "Xorg" > /dev/null && ! pgrep -x "Wayland" > /dev/null); then
    TERMINAL_NAME="unknown"
else
    PARENT_PID=$(ps -o ppid= -p $$)
    TERMINAL_NAME=$(ps -o comm= -p "$PARENT_PID" | sed 's/-$//')
fi
SHELL_NAME=$(basename "$SHELL")

# Detect the package manager
PACKAGE_MANAGERS=("apt" "yum" "dnf" "pacman")
for PM in "${PACKAGE_MANAGERS[@]}"; do
    if command -v $PM &> /dev/null; then
        PACKAGE_MANAGER=$PM
        break
    fi
done
if [ -z "$PACKAGE_MANAGER" ]; then
    error "Package manager not supported."
elif [ "$PACKAGE_MANAGER" == "apt" ]; then
    sudo apt update || error "Failed to update package list."
fi

# Install missing dependencies
declare -A DEPENDENCIES
DEPENDENCIES=(
    ["autojump"]="autojump"
    ["bat"]="bat"
    ["curl"]="curl"
    ["unzip"]="unzip"
    ["ripgrep"]="rg"
    ["nodejs"]="node"
    ["npm"]="npm"
    ["xclip"]="xclip"
)
MISSING_DEPENDENCIES=()
for PACKAGE in "${!DEPENDENCIES[@]}"; do
    COMMAND=${DEPENDENCIES[$PACKAGE]}
    if [ ! -x "/usr/bin/$COMMAND" ] && ! timeout 5s command -v $COMMAND &> /dev/null; then
        MISSING_DEPENDENCIES+=($PACKAGE)
    fi
done
if [ ${#MISSING_DEPENDENCIES[@]} -ne 0 ]; then
    echo "Installing missing dependencies: ${MISSING_DEPENDENCIES[@]}..."
    for DEP in "${MISSING_DEPENDENCIES[@]}"; do
        sudo ${PACKAGE_MANAGER} install -y "$DEP" || warning "Failed to install $DEP."
    done
else
    echo "All dependencies are already installed."
fi

# Install zsh if required
if ! command -v zsh &> /dev/null; then
    read -p "zsh is not installed. Do you want to install zsh? (Y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "Installing zsh and oh-my-zsh..."
        sudo ${PACKAGE_MANAGER} install -y zsh || error "Failed to install zsh."
    else
        warning "zsh installation skipped."
    fi
fi

# Install oh-my-zsh and plugins if zsh is installed
if command -v zsh &> /dev/null; then
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh and plugins..."

        sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" ||
            error "Failed to install oh-my-zsh."

        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &&
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &&
        git clone https://github.com/fdellwing/zsh-bat.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat ||
            error "Failed to install plugins."
    else
        echo "oh-my-zsh is already installed."
    fi

    if [ "$SHELL_NAME" != "zsh" ]; then
        echo "Changing default shell to zsh..."
        chsh -s $(which zsh) || error "Failed to change default shell to zsh."
    fi
else
    warning "zsh is not installed. Skipping oh-my-zsh installation."
fi

# Install Monofur Nerd Font if not installed
if ! fc-list | grep -qi "Monofur Nerd Font"; then
    echo "Installing Monofur Nerd Font..."

    if ! command -v curl &> /dev/null; then
        echo "Installing curl..."
        sudo "$PACKAGE_MANAGER" install -y curl || error "Failed to install curl."
    fi

    LATEST_VERSION=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    if [ -z "$LATEST_VERSION" ]; then
        warning "Failed to fetch the latest version. Defaulting to v3.2.1."
        LATEST_VERSION="v3.2.1"
    fi

    wget -qO- "https://github.com/ryanoasis/nerd-fonts/releases/download/$LATEST_VERSION/Monofur.zip" -O /tmp/Monofur.zip &&
    unzip -o /tmp/Monofur.zip -d ~/.local/share/fonts &&
    fc-cache -fv ||
        { rm /tmp/Monofur.zip &> /dev/null; error "Failed to install Monofur Nerd Font."; }
fi

# Load terminal profiles
case "$TERMINAL_NAME" in
    "gnome-terminal")
        echo "Loading GNOME Terminal profiles..."
        dconf load /org/gnome/terminal/legacy/profiles:/ < "$LINUX_DIR/profiles/gnome-terminal-profiles.dconf" ||
            error "Failed to load GNOME Terminal profiles."
        ;;
    "konsole")
        echo "Loading Konsole profiles..."
        cp -r "$LINUX_DIR/profiles/konosle" "$HOME/.local/share/"
        ;;
    *)
        warning "Terminal profile loading not supported for $TERMINAL_NAME."
        ;;
esac

install_neovim() {
    echo "Installing the latest version of Neovim..."

    wget -qO- "https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz" -O /tmp/nvim-linux64.tar.gz &&
    tar xzvf /tmp/nvim-linux64.tar.gz -C /tmp &&
    sudo mv /tmp/nvim-linux64/bin/nvim /usr/local/bin/nvim ||
        { rm -rf /tmp/nvim-linux64 /tmp/nvim-linux64.tar.gz &> /dev/null; error "Failed to install Neovim."; }
}

# Check if Neovim is installed and update if necessary
if command -v nvim &> /dev/null; then
    INSTALLED_VERSION=$(nvim --version | head -n 1 | awk '{print $2}')
    LATEST_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -Po '"tag_name": "\K.*?(?=")' | sed 's/v//')

    if [[ "$INSTALLED_VERSION" < "0.9" ]]; then
        install_neovim
    elif [[ "$INSTALLED_VERSION" < "$LATEST_VERSION" ]]; then
        read -p "A newer version of Neovim ($LATEST_VERSION) is available. Do you want to update? (Y/n): " choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            install_neovim
        fi
    fi
else
    install_neovim
fi

# Copy dotfiles to the home directory
echo "Copying files from $LINUX_DIR/dots to the home directory..."
cp -r "$LINUX_DIR/dots/." "$HOME/" ||
    error "Failed to copy files to the home directory."
