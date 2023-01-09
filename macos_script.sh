#!/bin/bash

# ASCII art banner
echo "
   __  __  __  __  __  __  __  __  __  __  __  __
  /  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \
 ( W   A   K   E   D   O   G )
  \__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/
"

# Create a function to prompt the user for confirmation before executing a block of code
function ConfirmExecution() {
    read -p "$1 (Y/N)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# 1. Harden the system by enabling built-in security features
# 1.1 Enable the firewall
if !(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep "Firewall is enabled."); then
    if ConfirmExecution "Do you want to enable the firewall?"; then
        /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    fi
fi

# 1.2 Enable FileVault
if !(fdesetup status | grep "FileVault is On."); then
    if ConfirmExecution "Do you want to enable FileVault?"; then
        # Set a strong, randomly-generated password for the FileVault recovery key
        recoveryKeyPassword=$(openssl rand -base64 32)
        # Enable FileVault with the recovery key password
        fdesetup enable -recoverykey "$recoveryKeyPassword"
    fi
fi

# 1.3 Enable the built-in firewall logging
if !(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode | grep "Logging mode is on."); then
    if ConfirmExecution "Do you want to enable firewall logging?"; then
        /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
    fi
fi

# 2. Clean the system by removing unnecessary or harmful software
# 2.1 Remove harmful software (e.g. malware, adware)
if ConfirmExecution "Do you want to scan for and remove harmful software?"; then
    # Use Malwarebytes to scan for and remove harmful software
    sudo /Library/Application\ Support/Malwarebytes/MBAM/mbam
fi

# 3. Debloat the system by removing unnecessary features and components
# 3.1 Remove unnecessary MacOS features and components
if ConfirmExecution "Do you want to remove unnecessary MacOS features and components?"; then
    # Use Homebrew to remove unnecessary MacOS features and components
    # List of unnecessary features and components can be customized to suit the user's needs
    # Example: remove Dashboard, iCal, and Photos
    brew uninstall dashboard-client
    brew uninstall ical
    brew cask uninstall photos
fi

# 3.2 Remove bloatware (i.e. pre-installed manufacturer software)
if ConfirmExecution "Do you want to remove bloatware?"; then
    # List of bloatware can be customized to suit the user's needs
    # Example: remove Candy Crush, Farmville, and other Mac App Store games
    mas uninstall 1147396723 # Candy Crush Saga
    mas uninstall 585829637 # Farmville
    mas uninstall 803453959 # Spaceteam
    mas uninstall 918858936 # A Dark Room
    mas uninstall 539883307 # iBooks
    mas uninstall 407963104 # Pixelmator
    mas uninstall 682658836 # GarageBand
    mas uninstall 497799835 # Xcode
fi

# 4. Customize system settings to improve security and performance
# 4.1 Enable automatic updates
if !(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled | grep 1); then
    if ConfirmExecution "Do you want to enable automatic updates?"; then
        defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
    fi
fi

# 4.2 Enable strong passwords
if !(defaults read /Library/Preferences/com.apple.loginwindow PasswordMinLength | grep 8); then
    if ConfirmExecution "Do you want to enable strong passwords (minimum length 8 characters)?"; then
        defaults write /Library/Preferences/com.apple.loginwindow PasswordMinLength -int 8
    fi
fi

# 4.3 Set the power plan to high performance
if !(pmset -g power | grep "AC Power" | grep -q "performance"); then
    if ConfirmExecution "Do you want to set the power plan to high performance?"; then
        pmset -c powernap 0
        pmset -c autopoweroff 0
        pmset -c standby 0
        pmset -c sleep 0
        pmset -c displaysleep 0
        pmset -c disktimeout 0
        pmset -c ttyskeepawake 1
        pmset -c acwake 0
        pmset -c lidwake 0
        pmset -c autopoweroffdelay 0
        pmset -c standbydelay 0
        pmset -c sleepdelay 0
        pmset -c displaysleepdelay 0
        pmset -c hibernatemode 0
        pmset -c disksleep 0
        pmset -c powernap 0
        pmset -c tcpkeepalive 0
        pmset -c acpower 1
    fi
fi

# 5. Optimize system performance
# 5.1 Defragment hard drive
if ConfirmExecution "Do you want to defragment the hard drive?"; then
    # Choose the hard drive to defragment (e.g. /dev/disk1)
    read -p "Enter the hard drive to defragment (e.g. /dev/disk1): " hardDrive
    ufs_compact -y "$hardDrive"
fi

# 5.2 Clear temporary files
if ConfirmExecution "Do you want to clear temporary files?"; then
    # Use the built-in Disk Utility tool to clear temporary files
    diskutil list
    read -p "Enter the volume to clean (e.g. disk1s2): " volume
    diskutil clean "$volume"
fi

# 5.3 Disable unnecessary services
if ConfirmExecution "Do you want to disable unnecessary services?"; then
    # List of unnecessary services can be customized to suit the user's needs
    # Example: disable print spooler service if there are no printers installed
    if [[ $(lpstat -p | wc -l) -eq 0 ]]; then
        launchctl unload -w /System/Library/LaunchDaemons/org.cups.cupsd.plist
    fi
fi

# 6. Perform a system backup
if ConfirmExecution "Do you want to perform a system backup?"; then
    # Choose a backup location (e.g. external hard drive, network share)
    read -p "Enter the backup location (e.g. /Volumes/Backup): " backupLocation
    # Set the date and time as the backup folder name
    dateTime=$(date +%Y-%m-%d_%H-%M-%S)
    backupFolder="$backupLocation/$dateTime"
    # Create the backup folder
    mkdir "$backupFolder"
    # Perform the backup using the built-in Time Machine tool
    tmutil snapshot "$backupFolder"
fi

# 7. Restart the system
if ConfirmExecution "Do you want to restart the system now?"; then
    shutdown -r now
fi