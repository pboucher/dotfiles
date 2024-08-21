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

    if ! type op &> /dev/null; then
        echo "Installing 1Password..."
        brew install --cask --adopt 1password
        brew install --cask --adopt 1password-cli
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
