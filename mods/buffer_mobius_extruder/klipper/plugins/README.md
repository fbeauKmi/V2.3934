
Small change in [belay.py](https://github.com/Annex-Engineering/Belay/blob/main/Klipper_Stuff/klippy_module/belay.py) to manually enable/disable multiplier
## Gcode reference

``BELAY_ENABLE BELAY=<NAME> ENABLE=0|1``

## Status reference

The following information is available in belay some_name objects:

- `printer["belay <config_name>"].last_state`: Returns `True` if the belay's sensor is in a triggered state (indicating its slider is compressed).
- `printer["belay <config_name>"].enabled`: Returns `True` if the belay is currently enabled.
- `printer["belay <config_name>"].multiplier`: mulitiplier in use (can be `multiplier_low` or `multiplier_high` or `1.0`)
- `printer["belay <config_name>"].multiplier_low`: multiplier_low value
- `printer["belay <config_name>"].multiplier_high`: multiplier_high value

