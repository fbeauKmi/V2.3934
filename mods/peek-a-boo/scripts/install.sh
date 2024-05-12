#! /bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
KS_service_name="KlipperScreen"
KS_service_file="/etc/systemd/system/${KS_service_name}.service"
BL_service_name="KlipperScreen_backlight"
BL_service_file="/etc/systemd/system/${BL_service_name}.service"
BL_service_script="/usr/bin/python3 $SCRIPTPATH/klipperscreen_backlight.py"
PACKAGES="xdotool"

Red='\033[0;31m'
Green='\033[0;32m'
Cyan='\033[0;36m'
Normal='\033[0m'

echo_text ()
{
    printf "${Normal}$1${Cyan}\n"
}

echo_error ()
{
    printf "${Red}$1${Normal}\n"
}

echo_ok ()
{
    printf "${Green}$1${Normal}\n"
}

install_packages()
{
    echo_text "Update package data"
    sudo apt-get update

    echo_text "Checking for broken packages..."
    output=$(dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\n' | grep -E ^.[^nci])
    if [ $? -eq 0 ]; then
        echo_text "Detected broken packages. Attempting to fix"
        sudo apt-get -f install
        output=$(dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\n' | grep -E ^.[^nci])
        if [ $? -eq 0 ]; then
            echo_error "Unable to fix broken packages. These must be fixed before KlipperScreen can be installed"
            exit 1
        fi
    else
        echo_ok "No broken packages"
    fi

    echo_text "Installing $PACKAGES"
    
    sudo apt-get install -y $PACKAGES
    if [ $? -eq 0 ]; then
        echo_ok "$PACKAGES Installed"
    else
        echo_error "Installation of $PACKAGES failed"
        exit 1
    fi

}

check_requirements()
{
    echo_text "Checking for KlipperScreen service installed"
    if [ ! -e "$KS_service_file" ]; then
        echo_error "Klipperscreen must be installed as service"
        exit 1
    fi
    echo_ok "Klipperscreen service found"
}

install_systemd_service()
{
    echo_text "Installing $BL_service_name service"
    cat <<EOF | sudo tee "$BL_service_file" > /dev/null
[Unit]
Description=$BL_service_name
After=$KS_service_name.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=$BL_service_script
WorkingDirectory=$SCRIPTPATH
User=$USER

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl unmask $BL_service_name.service
    sudo systemctl daemon-reload
    sudo systemctl start $BL_service_name
    sudo systemctl enable $BL_service_name
    sudo systemctl set-default multi-user.target

    echo_ok "Service $service_name installed"
}

start_backlight()
{
    echo_text "Starting service..."
    sudo systemctl stop $BL_service_name
    sudo systemctl start $BL_service_name
    echo_ok "Done..."
}

if [ "$EUID" == 0 ]
    then echo_error "Please do not run this script as root"
    exit 1
fi

check_requirements
install_packages
install_systemd_service
start_backlight