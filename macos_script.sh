#!/bin/bash

# ASCII art banner
echo "
   __  __  __  __  __  __  __ 
  /  \/  \/  \/  \/  \/  \/  \
 ( W   A   K   E   D   O   G )
  \__/\__/\__/\__/\__/\__/\__/
"

# Function to prompt for confirmation
ConfirmExecution() {
    read -p "$1 (Y/N)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Check for root privileges
if [ "$(id -u)"!= "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# 1. Harden the system
# 1.1 Enable the firewall
if!(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep "Firewall is enabled."); then
    if ConfirmExecution "Enable the firewall?"; then
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    fi
fi

# 1.2 Enable FileVault
if!(fdesetup status | grep "FileVault is On."); then
    if ConfirmExecution "Enable FileVault?"; then
        # Generate a strong password for the FileVault recovery key
        recoveryKeyPassword=$(openssl rand -base64 32)
        # Enable FileVault with the recovery key password
        sudo fdesetup enable -recoverykey "$recoveryKeyPassword"
    fi
fi

# 1.3 Enable firewall logging
if!(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode | grep "Logging mode is on."); then
    if ConfirmExecution "Enable firewall logging?"; then
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
    fi
fi

# 2. Clean the system
# 2.1 Scan for and remove harmful software
if ConfirmExecution "Scan for and remove harmful software?"; then
    # Assuming Malwarebytes is installed and configured correctly
    sudo /Applications/Malwarebytes.app/Contents/MacOS/Malwarebytes
fi

# 3. Debloat the system
# 3.1 Remove unnecessary MacOS features and components
if ConfirmExecution "Remove unnecessary MacOS features and components?"; then
    # Update Homebrew and install cleanup tools
    brew update && brew install homebrew/cask-versions/microsoft-autoupdater
    brew uninstall --force --cask microsoft-autoupdater
fi

# 3.2 Remove bloatware
if ConfirmExecution "Remove bloatware?"; then
    # Example: remove Candy Crush, Farmville, etc.
    mas uninstall 1147396723 # Candy Crush Saga
    mas uninstall 585829637 # Farmville
    # Add more as needed
fi

# 4. Customize system settings
# 4.1 Enable automatic updates
if!(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled | grep -q 1); then
    if ConfirmExecution "Enable automatic updates?"; then
        sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
    fi
fi

# 4.2 Enable strong passwords
if!(defaults read /Library/Preferences/com.apple.loginwindow PasswordMinLength | grep -q 8); then
    if ConfirmExecution "Enable strong passwords (min. 8 chars)?"; then
        sudo defaults write /Library/Preferences/com.apple.loginwindow PasswordMinLength -int 8
    fi
fi

# 4.3 Set power plan to high performance
if!(pmset -g | grep -q "AC Power" | grep -q "performance"); then
    if ConfirmExecution "Set power plan to high performance?"; then
        sudo pmset -a gpcurrentpowerlimit 100%
        sudo pmset -a disksleep 0
        sudo pmset -a sleep 0
        sudo pmset -a standby 0
        sudo pmset -c acwake 0
        sudo pmset -c lidwake 0
    fi
fi

# 5. Optimize system performance
# 5.1 Clear temporary files
if ConfirmExecution "Clear temporary files?"; then
    # Use Disk Utility to clear temporary files
    sudo diskutil list
    read -p "Enter the volume to clean (e.g., disk1s2): " volume
    sudo diskutil clean "$volume"
fi

# 6. Perform a system backup
if ConfirmExecution "Perform a system backup?"; then
    # Assume Time Machine is set up
    sudo tmutil startbackup
fi

# 7. Restart the system
if ConfirmExecution "Restart the system now?"; then
    sudo shutdown -r now
fi
