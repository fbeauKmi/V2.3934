#! /usr/bin/python3
# klipperscreen_backlight.py
# Turn on/off a Waveshare DSI display according a button state
# author: FbeauKmi
# Licence : GPL 3.0
# version 0.1 : initial release 

import RPi.GPIO as GPIO
import time
import subprocess
import re
import os  

# Set environment variables
os.environ['DISPLAY'] = ':0'
user_home = os.path.expanduser('~')
os.environ['XAUTHORITY'] = f'{user_home}/.Xauthority'

# Set the GPIO mode
GPIO.setmode(GPIO.BCM)

# Define constants
button_pin = 27 # button GPIO on Pi 
xinput_id = 6   # Touchscreen xinput id

# Set up the button GPIO as an input with a pull-up resistor
GPIO.setup(button_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Check if Monitor is on
def is_dpms_on():
    try:
        # Capture xset q  output
        result = subprocess.check_output(['xset', 'q']).decode('utf-8')
        return 'Monitor is On' in result
    
    except subprocess.CalledProcessError:
        # xset command fails
        print("Error: Unable to check DPMS status.")
        return False

# Check if Touchpanel is active
def is_xinput_on():
    try:
        # Capture xinput list-props output
        result = subprocess.check_output(['xinput','list-props', str(xinput_id)]).decode('utf-8')
        return bool(re.search(r'Device Enabled \(\d+\):\s+1', result))
        
    except subprocess.CalledProcessError:
        # xinput command fails
        print("Error: Unable to check Xinput status.")
        return False

def set_display_on():
    # Enable touchpanel
    if not is_xinput_on():
        subprocess.run(['xinput', 'enable', str(xinput_id)])
        print("enable touchpanel")

    # Emulate touch to wakeup display
    subprocess.run(['xdotool', 'mousemove', '5', '5', 'click', '1'])
    print("wake_up")

def set_display_off():
    #Disable backlight
    if is_dpms_on():
        time.sleep(0.1)
        subprocess.run(['xset', 'dpms', 'force', 'off'])
        print("suspend")

    # Disable touchpanel
    if is_xinput_on() :
        subprocess.run(['xinput', 'disable', str(xinput_id)])
        print("disable touchpanel")

triggered = True

try:
    # Waiting for button events... 
    while True:
        # Check the button state every 500ms
        if GPIO.input(button_pin) == GPIO.LOW:
            set_display_off()
            triggered = True 
            
        elif triggered:  # Catch only rising state
            set_display_on()
            triggered = False
        time.sleep(0.5)


except KeyboardInterrupt:
    # Exiting...
    GPIO.cleanup()
