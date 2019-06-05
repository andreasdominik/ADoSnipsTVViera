#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips Console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# * MQTT-Topic as String
# * MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style)
#
"""
function switchOnOffActions(topic, payload)

    Switch on the TV set by power on a GPIU-controlled switch.
"""
function switchOnOffActions(topic, payload)

    # log:
    println("[ADoSnipsTVViera]: action switchOnOffActions() started.")

    # ignore, if not responsible (other device):
    #
    device = Snips.extractSlotValue(payload, SLOT_DEVICE)
    if device == nothing || !( device in ["TV", "sound"] )
        return false
    end


    # get other slots and test if OK:
    #
    room = Snips.extractSlotValue(payload, SLOT_ROOM)
    if room == nothing
        room = Snips.getSiteId()
    end

    onOrOff = Snips.extractSlotValue(payload, SLOT_ON_OFF)
    if onOrOff == nothing or !(onOrOff in ["ON", "OFF"])
        Snips.publishEndSession(:dunno)
        return true
    end


    # get from config.ini:
    #
    tvIP = Snips.getConfig(INI_TV_IP)
    if tvIP == nothing
        Snips.publishEndSession(:noip)
        return false
    end
    tvGPIO = Snips.getConfig(INI_TV_GPIO)
    if tvGPIO == nothing
        Snips.publishEndSession(:nogpio)
        return false
    end


    if device == "TV"
        if onOrOff == "ON"
            Snips.publishEndSession(:switchon)
            switchTVon(tvIP, tvGPIO)
        else
            Snips.publishEndSession(:switchoff)
            switchTVoff(tvIP, tvGPIO)
        end
    elseif device == "sound"
        Snips.publishEndSession(:ok)
        muteTV(tvIP)
    end

    return false
end
