#!/usr/bin/env bash

source ./lib/echos.sh
source ./lib/installers.sh

bot "01001000 01100101 01101100 01101100 01101111"

grep 'user = GITHUBUSER' ./home/.gitconfig > /dev/null 2>&1
if [[ $? = 0 ]]; then
    echo -e "\n"
    read -r -p "What is your github username? " githubuser

    fullname=`osascript -e "long user name of (system info)"`

    if [[ -n "$fullname" ]]; then
        lastname=$(echo $fullname | awk '{print $2}');
        firstname=$(echo $fullname | awk '{print $1}');
    fi

    if [[ -z $lastname ]]; then
        lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //"`
    fi
    
    if [[ -z $firstname ]]; then
        firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //"`
    fi

    email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`

    if [[ ! "$firstname" ]];then
        response='n'
    else
        echo -e "I see that your full name is $COL_YELLOW$firstname $lastname$COL_RESET"
        read -r -p "Is this correct? [Y|n] " response
    fi

    if [[ $response =~ ^(no|n|N) ]];then
        read -r -p "What is your first name? " firstname
        read -r -p "What is your last name? " lastname
    fi
    
    fullname="$firstname $lastname"

    bot "Nice to meet you, $fullname!\n"

    if [[ ! $email ]]; then
        response='n'
    else
        echo -e "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
        read -r -p "Is this correct? [Y|n] " response
    fi

    if [[ $response =~ ^(no|n|N) ]]; then
        read -r -p "What is your email? " email
        if [[ ! $email ]]; then
            error "you must provide an email to configure .gitconfig"
            exit 1
        fi
    fi

    running "replacing items in .gitconfig with your info ($COL_YELLOW$fullname, $email, $githubuser$COL_RESET)"

    sed -i '' "s/GITHUBFULLNAME/$firstname $lastname/" ./home/.gitconfig;
    sed -i '' 's/GITHUBEMAIL/'$email'/' ./home/.gitconfig;
    sed -i '' 's/GITHUBUSER/'$githubuser'/' ./home/.gitconfig;
    ok
fi

# Set up ZSH
action "installing/updating zsh"
install_brew zsh

CURRENTSHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')

if [[ "$CURRENTSHELL" != "/usr/local/bin/zsh" ]]; then
    bot "setting zsh as your shell (password required)"
    sudo dscl . -change /Users/$USER UserShell $SHELL /usr/local/bin/zsh > /dev/null 2>&1
    ok
fi

action "installing spaceship ZSH theme"
unlink /Users/$(whoami)/.oh-my-zsh/custom/themes/spaceship.zsh-theme > /dev/null 2>&1
ln -s ~/.dotfiles/zsh/themes/spaceship/spaceship.zsh-theme /Users/$(whoami)/.oh-my-zsh/custom/themes/spaceship.zsh-theme

# Symlink dotfiles
bot "creating symlinks for dotfiles..."
pushd home > /dev/null 2>&1
now=$(date +"%Y.%m.%d.%H.%M.%S")

for file in .*; do
    if [[ $file == "." || $file == ".." ]]; then
        continue
    fi

    running "~/$file"

    # If the file exists, back it up
    if [[ -e ~/$file ]]; then
        mkdir -p ~/.dotfiles_backup/$now
        mv ~/$file ~/.dotfiles_backup/$now/$file
        echo "backup saved as ~/.dotfiles_backup/$now/$file"
    fi

    unlink ~/$file > /dev/null 2>&1
    ln -s ~/.dotfiles/home/$file ~/$file
    echo -en "\tlinked "; ok
done

popd > /dev/null 2>&1

#########################################
bot "Standard System Changes"
#########################################

running "Disable the crash reporter"
defaults write com.apple.helpviewer DevMode -bool true;ok

running "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1;ok

#########################################
bot "System Input Changes"
#########################################

running "Disable 'natural' (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false;ok

running "Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40;ok

running "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3;ok

running "Disable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false;ok

running "Set a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 10;ok

#########################################
bot "System Display Changes"
#########################################

running "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2;ok

bot "Installation complete. Please quit this terminal and reload."