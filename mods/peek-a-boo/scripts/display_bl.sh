#!/bin/bash

# Get the current user's home directory
user_home=$(getent passwd "$USER" | cut -d: -f6)

export DISPLAY=:0
export XAUTHORITY=$user_home/.Xauthority

if [ "$1" == "on" ]; then
    xdotool mousemove 5 5 click 1
    xinput enable 6
    echo "display on"
elif [ "$1" == "off" ]; then
    xset dpms force soff
    xinput disable 6
    echo "display off"
else
    echo "Invalid parameter. Please use 'on' or 'off'."
fi
