
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
const SLOT_CHANNEL = "channel"

# name of entry in config.ini:
#
const INI_TV_IP = :tv_ip
const INI_TV_GPIO = :tv_gpio
const INI_CHANNEL = :tv_channel

#
# link between actions and intents:
# intent is linked to action{Funktion}
# Language-dependent settings:
#
if LANG == "de"
    Snips.registerIntentAction("ADoSnipsOnOffDE", switchOnOffActions)
else
    Snips.registerIntentAction("ADoSnipsOnOffDE", switchOnOffActions)
end
