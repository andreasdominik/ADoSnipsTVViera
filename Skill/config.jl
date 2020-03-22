# DO NOT CHANGE THE FOLLOWING LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = false
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)
#
# language settings:
# Snips.LANG in QnD(Snips) is defined from susi.toml or set
# to "en" if no susi.toml found.
# This will override LANG by config.ini if a key "language"
# is defined locally:
#
if Snips.isConfigValid(:language)
    Snips.setLanguage(Snips.getConfig(:language))
end
# or LANG can be set manually here:
# Snips.setLanguage("fr")
#
# set a local const with LANG:
#
const LANG = Snips.getLanguage()
#
# END OF DO-NOT-CHANGE.


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
