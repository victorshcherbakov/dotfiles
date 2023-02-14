#!/bin/bash

if [ ! -x "$(command -v curl)" ]; then
    echo "'curl' could not be found."
    exit
fi

if [ ! -x "$(command -v make)" ]; then
    echo "'curl' could not be found."
    exit
fi

if [ ! -x "$(command -v fish)" ] && [ ! -d "$HOME/.config/fish" ]; then
    echo "fish installation."
else
    echo "Skip fish installation"
fi
