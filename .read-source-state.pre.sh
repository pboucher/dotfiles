#!/bin/sh

case "$(uname -s)" in
Darwin)
    # Install Homebrew if it's not installed
    if ! type brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # If we didn't have homebrew installed, this is the first time we're installing so get age so that we can
        # decrypt the dotfiles
        eval "$(/opt/homebrew/bin/brew shellenv)"
        brew install age
    fi

    # Install 1Password if it's not installed
    if ! type op &> /dev/null; then
        echo "Installing 1Password..."
        brew install --cask --adopt 1password
        brew install --cask --adopt 1password-cli
        echo "Opening 1Password. Please log into your account and enable CLI integration."
        open "/Applications/1Password.app"
        echo "Press Enter to continue."
        read
    fi

    # Install Oh My Zsh if it isn't present
    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # Setup SSH keys taken from 1Password so that chezmoi can encrypt/decrypt files
    if [[ ! -d "${HOME}/.ssh" ]]; then
        mkdir -p "${HOME}/.ssh"
        chmod 700 "${HOME}/.ssh"
    fi
    if [[ ! -f "${HOME}/.ssh/chezmoi_ed25519.pub" ]]; then
        op read "op://Private/chezmoi dotfile encryption/public key" > "${HOME}/.ssh/chezmoi_ed25519.pub"
    fi
    if [[ ! -f "${HOME}/.ssh/chezmoi_ed25519" ]]; then
        op read "op://Private/chezmoi dotfile encryption/private key" > "${HOME}/.ssh/chezmoi_ed25519"
    fi
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
