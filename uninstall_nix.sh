#!/bin/sh

CONTINUE_ON_ERROR=${CONTINUE_ON_ERROR:-false}
DRY_RUN=${DRY_RUN:-false}

# Function to check the status of the last command and exit if it failed
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        if [ "$CONTINUE_ON_ERROR" = false ]; then
            exit 1
        else
            # ask the user to continue if the CONTINUE_ON_ERROR flag is set
            echo "Do you want to continue? [y/n]"
            read -r response
            if [ "$response" != "y" ]; then
                exit 1
            fi
        fi
    fi
}

# Function to execute a command, or just print it if in dry-run mode
execute() {
    if [ "$DRY_RUN" = true ]; then
        echo "Dry run: $*"
    else
        eval "$@"
        check_status "$2"
    fi
}

# Parse command line arguments
while [ "$1" != "" ]; do
    case $1 in
        -c | --continue-on-error ) CONTINUE_ON_ERROR=true ;;
        -d | --dry-run ) DRY_RUN=true ;;
        * ) echo "Invalid option: $1"; exit 1 ;;
    esac
    shift
done

echo "Restoring the original shell configuration files..."
execute "sudo mv /etc/zshrc.backup-before-nix /etc/zshrc" "Failed to restore /etc/zshrc"
execute "sudo mv /etc/bashrc.backup-before-nix /etc/bashrc" "Failed to restore /etc/bashrc"
execute "sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc" "Failed to restore /etc/bash.bashrc"

echo "Stopping and removing the Nix daemon..."
execute "sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist" "Failed to unload org.nixos.nix-daemon.plist"
execute "sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist" "Failed to remove org.nixos.nix-daemon.plist"
execute "sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist" "Failed to unload org.nixos.darwin-store.plist"
execute "sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist" "Failed to remove org.nixos.darwin-store.plist"

echo "Removing the nixbld group and the _nixbuildN users..."
execute "sudo dscl . -delete /Groups/nixbld" "Failed to delete nixbld group"
for u in $(sudo dscl . -list /Users | grep _nixbld); do
    execute "sudo dscl . -delete /Users/$u" "Failed to delete user $u"
done

echo "Opening the vifs file for editing interactively..."
execute "sudo vifs" "Failed to open vifs for editing"

echo "Checking and removing synthetic.conf if it contains 'nix'..."
if [ -f /etc/synthetic.conf ]; then
    if grep -q "^nix$" /etc/synthetic.conf; then
        execute "sudo rm /etc/synthetic.conf" "Failed to remove /etc/synthetic.conf"
    else
        execute "sudo vi /etc/synthetic.conf" "Failed to edit /etc/synthetic.conf"
    fi
fi

echo "Removing the files Nix added to your system, except for the store..."
execute "sudo rm -rf /etc/nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels" "Failed to remove Nix files"

echo "Removing the Nix store..."
execute "sudo diskutil apfs deleteVolume /nix" "Failed to delete Nix volume"

echo "Showing the list of volumes to confirm that the Nix volume was removed..."
execute "diskutil list" "Failed to list volumes"

echo "Nix uninstallation completed successfully."
