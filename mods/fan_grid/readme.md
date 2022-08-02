# fan_grid #
![honeycomb fan grid](https://github.com/fbeauKmi/V2.3934/blob/main/mods/fan_grid/Images/20220729_223132_resized.jpg)
Main aim was to secure the fans

Parametric fan grid for V2.4 skirt, several models:
- Original (useless)
- Original with rings
- Honeycombed logo (ugly and inefficient but it was my first design)
- Honeycomb
- Triangle
- Diamond

## Usage ##
Open file with OpenScad and tune parameters as desired.

Parameters:

- Part : Part to generate : A or B or R1 version(determine rear pocket side), default = A
- Pattern_model : V2.4, V2.4_rings, Honeycomb, HoneyLogo, Triangle, Diamond, default = Honeycomb
![patterns](https://github.com/fbeauKmi/V2.3934/blob/main/mods/fan_grid/Images/patterns.png)
- Logo :  Voron, Voron2, none, default = Voron \
Logo model 
_only for Honeycomb, Triangle & Diamond_
![Logos](https://github.com/fbeauKmi/V2.3934/blob/main/mods/fan_grid/Images/logos.png)
- Pattern_angle : 0,30,60,90,120,150 in degree \
Rotate grid pattern 
- hole_dia : between 5 and 12 mm default = 9 mm \
holes max diameter in mm
_only for Honeycomb, Triangle & Diamond_ \
- line_width : between 0.4 and 1.2 mm default 0.8 mm \
grid wall min width in mm

- variable_line_width : between -1 to 1 \
change line hole size according to distance from center (0 : no change, negative : larger lines in perimeter, positive : larger lines in center)
_only for Honeycomb, Triangle & Diamond_
![variable_line_width](https://github.com/fbeauKmi/V2.3934/blob/main/mods/fan_grid/Images/variable_lw.png)

The Log window show the advised filename , copy it
Once done render the CAD (F6) then export to STL (F7) whith advised filename
