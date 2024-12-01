# This script checks for basic dependencies for the system, and installs them if they are not present.

# Checker function
check_command() {
    # $1: command to check
    # $2: install command
    if $2;
    then
        echo "$2 already installed"
    else
        echo "$2 not found, installing..."
        $3
    fi
}

# Install Homebrew
check_command "Homebrew" "command -v brew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

# Install iterm2
check_command "iTerm2" 'mdfind "kMDItemCFBundleIdentifier == com.googlecode.iterm2"' "brew install --cask iterm2"

# Install zsh
check_command "zsh" "command -v zsh" "brew install zsh"

# Install curl
check_command "command -v curl" "brew install curl"

# Install oh-my-zsh
check_command "oh-my-zsh" "[ -d ~/.oh-my-zsh ]" 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

# Install zsh-syntax-highlighting
check_command "zsh-syntax-highlighting" "[ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]" "brew install zsh-syntax-highlighting"

# Install zsh-autosuggestions
check_command "zsh-autosuggestions" "[ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]" "brew install zsh-autosuggestions"

# Install pipx
check_command "pipx" "command -v pipx" "brew install pipx"

# Install uv
check_command "uv" "command -v uv" "brew install uv"

# Install git
check_command "git" "command -v git" "brew install git"

# Install gh
check_command "gh" "command -v gh" "brew install gh"

# Install vscode
check_command "Visual Studio Code" 'mdfind "kMDItemCFBundleIdentifier == com.microsoft.VSCode"' "brew install --cask visual-studio-code"

# Install brave-browser
check_command "Brave Browser" 'mdfind "kMDItemCFBundleIdentifier == com.brave.Browser"' "brew install --cask brave-browser"

# Install logseq
check_command "Logseq" 'mdfind "kMDItemCFBundleIdentifier == com.electron.logseq"' "brew install --cask logseq"

# Install Task
check_command "Task" "command -v task" "brew install go-task"

# Download the repo to start the configuration
gh auth login
git clone https://github.com/davidilopez/macos-setup.git