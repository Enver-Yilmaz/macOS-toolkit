#!/bin/sh
# macOS Mojave ISO creator
#
# Author: https://github.com/thelamehacker
#
# License: GNU General Public License v3.0
# Release date: 28 September 2018
# Last updated: 24 October 2018
# Version: 0.2
# -----------------------------------------------------------------------------

formattedPrint() {
    echo
    echo "$@"
    echo
}

checkAdmin() {

    # Checking if the user has administrative rights
    if groups $USER | grep -q -w admin
        then
            makeISO
        else
            formattedPrint "User '$USER' doesn't seem to be an administrator! Please run this script with administrator rights."
    fi

}

makeISO() {
    # Creating a temporary disk image of 6 GB space in /tmp/ and mounting it
    # File system has been set to HFS+ Journaled for maximum compatibility.
    # This can be set to APFS on newer systems, or you can convert your file system to APFS post installation.

    formattedPrint "Creating and mounting a disk image..."

    hdiutil create -o /tmp/Mojave.cdr -size 6g -layout SPUD -fs HFS+J
    hdiutil attach /tmp/Mojave.cdr.dmg -noverify -mountpoint /Volumes/install_build

    formattedPrint "Copying downloaded files to our disk image and moving it to the Desktop..."

    # This is where sudo makes us a sandwich and we need those pesky administrative rights. 

    sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume /Volumes/install_build
    mv /tmp/Mojave.cdr.dmg ~/Desktop/InstallSystem.dmg
    hdiutil detach /Volumes/Install\ macOS\ Mojave

    formattedPrint "Converting the disk image to an ISO file and cleaning up..."

    hdiutil convert ~/Desktop/InstallSystem.dmg -format UDTO -o ~/Desktop/Mojave.iso
    mv ~/Desktop/Mojave.iso.cdr ~/Desktop/Mojave.iso
    rm ~/Desktop/InstallSystem.dmg

    formattedPrint "All done! You should have Mojave.iso on $USER's Desktop now."
}

formattedPrint "Welcome to macOS Mojave ISO creator tool"

# Prompting user to download the installer from app store if not done already

while true; do
    read -p "Have you downloaded the macOS Mojave installer from app store? " yn
    case $yn in
        [Yy]* ) checkAdmin; break;;
        [Nn]* ) echo "Please download macOS Mojave installer from app store and re-run this script. Goodbye."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
