# Enraged Rabbit Carrot Feeder
# Encoder only (version)
# Used to get filament_motion_sensor pos (MAX_FLOW_CALIBRATION macro)
# Copyright (C) 2021  Ette
#
# This file may be distributed under the terms of the GNU GPLv3 license.
import logging
import math
from random import randint
from . import pulse_counter
from . import force_move
import copy
import time

class EncoderCounter:

    def __init__(self, printer, pin, sample_time, poll_time, encoder_steps):
        self._last_time = self._last_count = None
        self._counts = 0
        self._encoder_steps = encoder_steps
        self._counter = pulse_counter.MCU_counter(printer, pin, sample_time,
                                    poll_time)
        self._counter.setup_callback(self._counter_callback)

    def _counter_callback(self, time, count, count_time):
        if self._last_time is None:  # First sample
            self._last_time = time
        elif count_time > self._last_time:
            self._last_time = count_time
            self._counts += count - self._last_count
        else:  # No counts since last sample
            self._last_time = time
        self._last_count = count

    def get_counts(self):
        return self._counts

    def get_distance(self):
        return (self._counts/2.) * self._encoder_steps

    def set_distance(self, new_distance):
        self._counts = int( ( new_distance / self._encoder_steps ) * 2. )

    def reset_counts(self):
        self._counts = 0.

class Ercf:
    LONG_MOVE_THRESHOLD = 70.
    SERVO_DOWN_STATE = 1
    SERVO_UP_STATE = 0
    SERVO_UNKNOWN_STATE = -1

    LOADED_STATUS_UNKNOWN = -1
    LOADED_STATUS_UNLOADED = 0
    LOADED_STATUS_PARTIAL = 1
    LOADED_STATUS_FULL = 2

    def __init__(self, config):
        self.config = config
        self.printer = config.get_printer()
        self.reactor = self.printer.get_reactor()
        self.printer.register_event_handler("klippy:connect",
                                            self.handle_connect)
       
      
        self.encoder_pin = config.get('encoder_pin')
        self.encoder_resolution = config.getfloat('encoder_resolution', 1.5,
                                            above=0.)
        self.encoder_sample_time = config.getfloat('encoder_sample_time', 0.1,
                                            above=0.)
        self.encoder_poll_time = config.getfloat('encoder_poll_time', 0.0001,
                                            above=0.)
        self._counter = EncoderCounter(self.printer, self.encoder_pin, 
                                            self.encoder_sample_time,
                                            self.encoder_poll_time, 
                                            self.encoder_resolution)
        self.log_level = config.getint('log_level', 1)

      

        # GCODE commands
        self.gcode = self.printer.lookup_object('gcode')
        self.gcode.register_command('ERCF_SET_LOG_LEVEL',
                    self.cmd_ERCF_SET_LOG_LEVEL,
                    desc = self.cmd_ERCF_SET_LOG_LEVEL_help)    
        self.gcode.register_command('ENCODER_POS', 
                    self.cmd_ERCF_DISPLAY_ENCODER_POS,
                    desc = self.cmd_ERCF_DISPLAY_ENCODER_POS_help)
        self.gcode.register_command('ENCODER_RESET', 
                    self.cmd_ENCODER_RESET,
                    desc = self.cmd_ENCODER_RESET_help)                    
 

    def handle_connect(self):
        self.encoder_sensor = self.printer.lookup_object("filament_motion_sensor encoder_sensor")

    def get_status(self, eventtime):
        encoder_pos = float(self._counter.get_distance())
        return {'encoder_pos': encoder_pos}

###################
# STATE FUNCTIONS #
###################
 

    cmd_ERCF_DISPLAY_ENCODER_POS_help = "Display current value of the ERCF encoder"
    def cmd_ERCF_DISPLAY_ENCODER_POS(self, gcmd):
        self._log_info("Encoder value is %.2f" % self._counter.get_distance())
    
    cmd_ENCODER_RESET_help = "Reset ERCF encoder value"
    def cmd_ENCODER_RESET(self, gcmd):
        self._counter.reset_counts()    
    


#####################
# LOGGING FUNCTIONS #
#####################
    cmd_ERCF_SET_LOG_LEVEL_help = "Set the log level for the ERCF"
    def cmd_ERCF_SET_LOG_LEVEL(self, gcmd):
        self.log_level = gcmd.get_int('LEVEL', 1)

    def _log_info(self, message):
        if self.log_level > 0:
            self.gcode.respond_info(message)        

    def _log_debug(self, message):
        if self.log_level > 1:
            self.gcode.respond_info("DEBUG: %s" % message)        

    def _log_trace(self, message):
        if self.log_level > 2:
            self.gcode.respond_info("TRACE: %s" % message)      

def load_config(config):
    return Ercf(config)
