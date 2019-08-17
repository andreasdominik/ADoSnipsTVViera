# ADoSnipsTVViera

This is a skill for Snips.ai to control a Panasonic Viera TV.

The skil is based on the QnD-framework, written in the
programming language Julia.
The full documentation of the framework is just work-in-progress!
Current version can be visited here:

 [Framework documentation](https://andreasdominik.github.io/ADoSnipsQnD/dev)


## Commands

Supported commands include:

* wakeup
* standby
* play, pause, mute, unmute


The skill uses the ON/OFF-Intent of the QnD-Framework (see documentation) for ON/OFF
and mute ON/OFF.

Intents for switching channel and pause/resume are available in German language;
however the code is multilangual and can  be used with other languages as well by
predefining the phrases to be spoken in the target language (see
framework documentation).

## API

The project includes a shell script for remote control of a TV via
uPnP/DLNA and CEC.
The script allows for submitting almost all commands present on an
IR-remote.

#### Supported commands
Volume control:
```
    getVolume
    setVolume value
    mute
    unMute
    getMute
```
  Numbers:
```
    0-9
```
  Source:
```
    TV
    AV
```
  Arrow navigation:
```
    right
    left
    up
    down
    center
    return
    exit
```
  Other:
```
    vieraLink
    epg
    info
```
  Pause/resume:
```
    play
    pause
```
  Only poweroff possible by DLNA (because TV is not listening in standby mode;
  wakeup/poweron is implemented via CEC):
```
    standby
    wakeup (wake up by CEC "on 0")
    susi (wakeup by CEC "as" on HDMI4)
```
  waits (in sec):
```
    wait1
    wait10
    wait20
```
## config.ini

Config parameters include:

```
[global]
language=de
[secret]
tv_sets=plasma
plasma:description=big TV in living room
plasma:room=default
plasma:ip=192.168.0.25
plasma:on_mode=cec
plasma:channels=ARD,ZDF,Arte,NDR,HR,SWR,MDR,BR,One,Servus
```

##### language
Language setting. Currently only `de` is supported, because intents in
other languages are missing.

##### tv_sets
Comma-separated list of unique names of the TV sets. One TV is possible in
each room (i.e siteId).

The following entries apply to each defined TV set:

##### &lt;unique name&gt;:description
Plain-text desctiption

##### &lt;unique name&gt;:room
`siteId` of the location of the tv. If no room is given in the command,
always the tv in the room is controlled, in which the command is
recorded.

##### &lt;unique name&gt;:ip
IP-address of TV

##### &lt;unique name&gt;:on_mode
One of `cec` or `upnp`: If the TV can be switched on via uPnP, this mode
should be used. If not, the workaround is to connect the RPi with
a HDMI-cable with the TV and switch on via CEC (`cec-client`).

##### &lt;unique name&gt;:channels
List of channels as confgured at the TV.


The list of TV channels must correspond with the list of values in the
slot `TV_channel` of the intents (ON_OFF and SwitchChannel). The sequence
determins the channel number; i.e. must correspond with the channels on
the TV set.

## Trigger

The app can be remote-controlled by activating a trigger via
MQTT.
The message must be published to the same MQTT host which is used
by Snips.
The required topic is `qnd/trigger/andreasdominik:ADoSnipsTVViera`,
the payload is something like:

```
{
  "target" : "qnd/trigger/andreasdominik:ADoSnipsTVViera",
  "origin" : "ADoSnipsScheduler",
  "sessionId": "1234567890abcdef",
  "siteId" : "default",
  "time" : "2019-06-09T12:48:53.61",
  "trigger" : {
    "room" : "default",
    "device" : "plasma",
    "commands" : [ "wakeup", "TV", "2", "center", "pause"],
    "delay" : 0.5
  }
}
```
All commands accepted by the script `viera.sh` are possible. They will be
executed with the specified delay between them.


## Ecosystem

The skill is part of the QnD-framework for Snips and intented to be used together
with the Skills `ADoSnipsHermesQnd<DE/EN>`, `ADoSnipsTVViera<DE/EN>`, `ADoSnipsFire<DE/EN>` and `ADoSnipsKodi<DE/EN>`. All together
works like charm in my HDTV setting with a Panasonic plasma, an Amazon Stick,
Libreelec/kodi on a RPi and Snips on a RPi (all connected via IP and HDMI/CEC).

In other settings (and all settings are different) the skills will
most probably *not* work out-of-the-box. However, the apps are developped
with 2 levels of API (like shown in the framework documentation) and implement
more functionality as currently used by the skills. Therefore it should be easy
to fork the apps and adapt the code to whatever is necessary just by calling the
proper API functions.

# Julia

This skill is (like the entire SnipsHermesQnD framework) written in the
modern programming language Julia (because Julia is faster
then Python and coding is much much easier and much more straight forward).
However "Pythonians" often need some time to get familiar with Julia.

If you are ready for the step forward, start here: https://julialang.org/
