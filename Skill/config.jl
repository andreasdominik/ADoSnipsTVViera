
# language settings:
# 1) set LANG to "en", "de", "fr", etc.
# 2) link the Dict with messages to the version with
#    desired language as defined in languages.jl:
#

lang = Snips.getConfig(:language)
const LANG = (lang != nothing) ? lang : "de"

# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = true
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)

# Slots:
# Name of slots to be extracted from intents:
#
const SLOT_ROOM = "room"
const SLOT_DEVICE = "device"
const SLOT_ON_OFF = "on_or_off"
const SLOT_CHANNEL = "TV_channel"
const SLOT_PAUSE = "tvPauseCmd"  # only valid value: pause, play

# name of entry in config.ini:
#
const INI_TV_LIST= :tv_sets
const INI_TV_ROOM = "room"
const INI_TV_IP = "ip"
const INI_CHANNELS = "channels"
const INI_ON_MODE = "on_mode"   # one of "upnp", "cec"

# link between actions and intents:
# intent is linked to action{Funktion}
#
Snips.registerIntentAction("ADoSnipsOnOff", switchOnOffActions)
Snips.registerIntentAction("SwitchChannel", switchChannelAction)
Snips.registerIntentAction("VieraPause", pauseAction)

Snips.registerTriggerAction("ADoSnipsTVViera", triggerTVVieraAction)
