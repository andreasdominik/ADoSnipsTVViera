# ADoSnipsTVViera

This is a template skill for the SnipsHermesQnD framework for Snips.ai
written in Julia.

 The full documentation of the framework is just work-in-progress!
 Current version can be visited here:

 [Framework documentation in devellopment](https://andreasdominik.github.io/ADoSnipsQnD/dev)

## Functionality

The skill uses the ON/OFF-Intent of the QnD-Framework (see documentation) for ON/OFF
and mute ON/OFF.

Intents for switching channel and pause/resume are available in German language;
however the code is multilagual and can  be used with other languages as well by
predefining the phrases to be spoken in the target language (see
framework documentation).

The project includes a shell script for remote control of a TV via
uPnP/DLNA and CEC ("on" is implementd via CEC and the HDMI between the TV and RPi,
because my old Panasonic does not support switch-on via uPnP).
The script allows for submitting almost all commands present on a
IR-remote.

## config.ini

The list of TV channels must correspond with the list of values in the
slot `TV_channel` of the intents (ON_OFF and SwitchChannel). The sequence
determins the channel number; i.e. must correspond with the channels on
the TV set.

# Julia

This skill is (like the entire SnipsHermesQnD framework) written in the
modern programming language Julia (because Julia is faster
then Python and coding is much much easier and much more straight forward).
However "Pythonians" often need some time to get familiar with Julia.

If you are ready, start here: https://julialang.org/
