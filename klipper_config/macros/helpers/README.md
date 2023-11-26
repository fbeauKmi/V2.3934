
# Helpers macros #
 
 - [air_filter_timer](./air_filtertimer.cfg) : Check use of Active Carbon Filter and Alerts when replacement is needed.
 - [nozzle_wipe](./nozzle_wipe.cfg) : Clean the nozzle whith brass brush
 - [prime_line](./prime_line.cfg) : All is in the filename
 - [filament](./filament.cfg) : Load, unload, change during print, tip shaping
 - [db_filament](../db_settings/) : Store datas about filaments (extrude_factor, pressure_advance, temperature, ...) 

## Db_filament.cfg

It's a bunch of macros which intends to store filament informations in printer instead of slicer and use it at print time. It is 
 connected to Frix-x calibration macros in order to simplify flow and pressure_advance storage.
### Install ###
Copy db_filament.cfg in your Klipper config folder, include it in your printer.cfg.
`[include <path>/db_filament.cfg]`

### DB_FILAMENT ###
    Usage :
    ```
    DB_FILAMENT [NAME="<filament_name>"] [DEL="<filament_name>"] [SETTING1=<setting1> ... SETTINGn=<settingn>]
    ```
This macro stores parameters in save_variables file
- `filament_name` is the name of the filament to add/update/delete. It is case insensitive and is stored as uppercase string
- `SETTINGS` are any parameters you want to store as long as the value is a float


To ensure compatibility whith Fluidd/Mainsail, default settings are sorted in the macro as follow.
Such format allows to easily add new parameter and lets GUI to present all parameters with their defaults values.
This is quite ugly, but it's the only way to get rid of the !#?¨¨$ regex of Mainsail.

```
##########################################################################################################
## COMMENT LINES OF UNWANTED SETTINGS, ADD YOUR OWN As you respect syntax below
## These lines are required to intialize default value
#                       Param name lower            =   Param name upper   default value
#                             |                              |                |
#                             V                              V                V
      {% set _=_d.update({  'bed_temp'              : params.BED_TEMP|default(90)|int                }) %}
      {% set _=_d.update({  'extruder_temp'         : params.EXTRUDER_TEMP|default(250)|int          }) %}
      {% set _=_d.update({  'chamber_temp'          : params.CHAMBER_TEMP|default(60)|int            }) %}
      {% set _=_d.update({  'chamber_min_temp'      : params.CHAMBER_MIN_TEMP|default(30)|int        }) %}
      {% set _=_d.update({  'pressure_advance'      : params.PRESSURE_ADVANCE|default(0.04)|float    }) %}
      {% set _=_d.update({  'extrude_factor'        : params.EXTRUDE_FACTOR|default(0.93)|float      }) %}
      {% set _=_d.update({  'retract_length'        : params.RETRACT_LENGTH|default(0.5)|float       }) %}
      {% set _=_d.update({  'retract_speed'         : params.RETRACT_SPEED|default(40)|float         }) %}
      {% set _=_d.update({  'unretract_extra_length': params.UNRETRACT_EXTRA_LENGTH|default(0)|float }) %}
      {% set _=_d.update({  'unretract_speed'       : params.UNRETRACT_SPEED|default(40)|float       }) %}
      {% set _=_d.update({  'fan_speed'             : params.FAN_SPEED|default(20)|float             }) %}
      {% set _=_d.update({  'soak_delay'            : params.SOAK_DELAY|default(1)|float             }) %}
      {% set _=_d.update({  'filter_speed'          : params.FILTER_SPEED|default(0.5)|float         }) %}
      {% set _=_d.update({  'z_adjust'              : params.Z_ADJUST|default(0)|float               }) %}
#     {% set _=_d.update({  'exhaust_fan_speed'     : params.EXHAUST_FAN_SPEED|default(0)|float      }) %}
#     {% set _=_d.update({  'your_own_param'        : params.YOUR_OWN_PARAM|default(0)|float         }) %}
#
##########################################################################################################
```
ONLY parameters in this list could be saved in the file. But parameters previously saved will be kept UNLESS you decide to clean the DBase

Storing a filament will not make it Active on your printer. Use FILAMENT to apply parameters to the printer

### FILAMENT ####
Usage:
    ```
    FILAMENT [NAME=<filament_name>]
    ```
Use to apply temperatures, Pressure_advance, extrude_factor, retract parameters to the printer. 
    Nota : Temperature targets will be set only at print time.
    If you don't want parameters to be set fill the `variable_unused` in [gcode_macro _FILAMENT] section

Others parameters can be used by START_PRINT, END_PRINT, CALIBRATION, ...
    DO NOT call FILAMENT macro inside your START_PRINT macro, it will gives you unwanted results as the datas will not be updated until the 

### FILAMENT_QUERY ###
Usage:
    ```
    FILAMENT_QUERY [NAME=<filament_name>]
    ```
Display all filaments stored or particular parameters


### DB_FILAMENT_FLOW ###
Usage:
    ```
    DB_FILAMENT_FLOW [NAME=<filament_name>]
    ```    
Store the result of COMPUTE_FLOW_MULTIPLIER as extrude_factor in the current Filament or selected filament_name

### DB_FILAMENT_PRESSURE_ADVANCE ###
Usage:
    ```
    DB_FILAMENT_PRESSURE_ADVANCE BAND=<band_number> [NAME=<filament_name>]
    ```    
Store pressure_advance determined by PRESSURE_ADVANCE_CALIBRATION just entering the BAND number (decimal values allowed)

# WHY ? #

- To store parameters of filament in the printer instead of the slicer. As each printer has his own behavior, parameters like extrude_factor, pressure_advance, extruder_temp are printer dependent. Maybe am I wrong ?..
- To easily store extrude_factor, pressure_advance from calibration macros.


# HOW ? #

In your macro you can get current parameters like this
    ```
    {% set _filament = printer['gcode_macro _FILAMENT].filament %}
    M104 S{_filament.extruder_temp}
    