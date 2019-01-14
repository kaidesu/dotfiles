#!/bin/bash

function install_cask() {
    running "brew cask $1"
    brew cask list $1 > /dev/null 2>&1 | true
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        action "brew cask install $1 $2"
        brew cask install $1
        if [[ $? != 0 ]]; then
            error "Failed to install $1! Aborting..."
        fi
    fi
    ok
}

function install_brew() {
    running "brew $1 $2"
    brew list $1 > /dev/null 2>&1 | true
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        action "brew install $1 $2"
        brew install $1 $2
        if [[ $? != 0 ]]; then
            error "failed to install $1! aborting..."
        fi
    fi
    ok
}

function install_node() {
    running "node -v"
    node -v
    if [[ $? != 0 ]]; then
        action "node not found, installing via homebrew"
        brew install node
        brew install nvm
        mkdir ~./nvm
    fi
    ok
}

function install_yarn() {
    running "yarn -v"
    yarn -v
    if [[ $? != 0 ]]; then
        action "yarn not found, installing via homebrew"
        brew install yarn
    fi
    ok
}

function install_php() {
    running "php -v"
    php -v
    if [[ $? != 0 ]]; then
        action "php not found, installing via homebrew"
        brew install php
    fi
    ok
}

function install_composer() {
    running "composer -v"
    composer -v
    if [[ $? != 0 ]]; then
        action "composer not found, installing via homebrew"
        brew install composer
    fi
    ok
}

function install_anaconda() {
    running "conda -V"
    conda -V
    if [[ $? != 0 ]]; then
        action "Anaconda not found, installing via homebrew"
        install_cask anaconda;ok
    else
        running "anaconda";ok
    fi
}