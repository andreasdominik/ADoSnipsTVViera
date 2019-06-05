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
        channel = Snips.extractSlotValue(payload, SLOT_CHANNEL)
        if channel == nothing
            channel = "unknown"
        end
        channelNo = channelToNumber(channel)

        if onOrOff == "ON"
            Snips.publishEndSession(:switchon)
            switchTVon(tvIP, tvGPIO)

            if channelNo > 0
                sleep(2)
                switchTVChannel(ip, channelNo)
            end
        else
            Snips.publishEndSession(:switchoff)
            switchTVoff(tvIP, tvGPIO)
        end


    elseif device == "sound"
        if onOrOff == "ON"
            Snips.publishEndSession(:unmute)
            unmuteTV(tvIP)
        else
            Snips.publishEndSession(:mute)
            muteTV(tvIP)
        end
    end

    return false
end


function channelToNumer(channel)

    channels = getConfig(INI_CHANNEL)
    if channels == nothing
        return 0
    end

    chNumber = findfirst(isequal(channel), channels)
    if chNumber == nothing
        return 0
    end

    return chNumber
end
