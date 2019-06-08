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
    switchOnOffActions(topic, payload)

Switch on the TV set with teh vierra-script.
"""
function switchOnOffActions(topic, payload)

    # log:
    #
    println("[ADoSnipsTVViera]: action switchOnOffActions() started.")

    # ignore, if not responsible (other device):
    #
    device = Snips.extractSlotValue(payload, SLOT_DEVICE)
    if device == nothing || !( device in ["TV", "volume"] )
        return false
    end

    onOrOff = Snips.extractSlotValue(payload, SLOT_ON_OFF)
    if onOrOff == nothing || !(onOrOff in ["ON", "OFF"])
        Snips.publishEndSession(:dunno)
        return true
    end

    # continue only, if a tv in room:
    #
    tv = getMatchedTv(payload)
    Snips.isValidOrEnd(tv, :no_tv_in_room) || return true

    # println(">>> $onOrOff, $device")
    if device == "TV"
        # check, if all config.ini entries are in correct:
        #
        channel = Snips.extractSlotValue(payload, SLOT_CHANNEL)
        channelNo = channelToNumber(channel, tv[:channels])

        if onOrOff == "ON"
            Snips.publishEndSession(:switchon)
            switchTVon(tv[:ip], tv[:on_mode])

            if channelNo > 0
                sleep(2)
                switchTVChannel(tv[:ip], channelNo)
            end
        else
            Snips.publishEndSession(:switchoff)
            switchTVoff(tv[:ip])
        end

    elseif device == "volume"
        if onOrOff == "ON"
            Snips.publishEndSession(:unmute)
            unmuteTV(tv[:ip])
        else
            Snips.publishEndSession(:mute)
            muteTV(tv[:ip])
        end
    end

    return false
end



function switchChannelAction(topic, payload)

    # log:
    #
    println("[ADoSnipsTVViera]: action switchChannelAction() started.")

    # continue only, if a tv in room:
    #
    tv = getMatchedTv(payload)
    Snips.isValidOrEnd(tv, :no_tv_in_room) || return true

    # println(">>> $onOrOff, $device")
    channel = Snips.extractSlotValue(payload, SLOT_CHANNEL)
    # println(">>> Slot: $SLOT_CHANNEL, $channel")
    channelNo = channelToNumber(channel, tv[:channels])

    if channelNo > 0

        Snips.publishEndSession("$(Snips.langText(:channel)) $channel")
        switchTVChannel(tv[:ip], channelNo)
    else
        Snips.publishEndSession(:error_channel)
    end

    return true
end



"""
    pauseAction(topic, payload)

Toggle between play and pause.
"""
function pauseAction(topic, payload)

    # log:
    #
    println("[ADoSnipsTVViera]: action pauseAction() started.")

    pause = Snips.extractSlotValue(payload, SLOT_PAUSE)
    if Snips.isConfigValid(INI_TV_IP) && pause != nothing &&
        pause in ["play", "pause"]

        if pause == "play"
            Snips.publishEndSession(:ok)
            pausePlayTV(Snips.getConfig(INI_TV_IP))
            return false
        else # pause == "pause"
            Snips.publishEndSession(:ok)
            pausePauseTV(Snips.getConfig(INI_TV_IP))
            return false
        end
    else
        Snips.publishEndSession(:dunno)
        return true
    end
end


# return a Dict with params of matched TV, or nothing, if something is wrong!
#
function getMatchedTv(payload)

    tv = nothing

    room = Snips.extractSlotValue(payload, SLOT_ROOM)
    if room == nothing
        room = Snips.getSiteId()
    end

    isConfigValid(INI_TV_LIST) || return nothing
    for tvName in getConfig(INI_TV_LIST)
        tvRoomName = "$(tv)_$INI_TV_ROOM"
        isConfigValid(tvRoomName) || return nothing
        if getConfig(tvRoomName) == room
            isConfigValid("$(tv)_$INI_TV_IP") || return nothing
            isConfigValid("$(tv)_$INI_ON_MODE") || return nothing
            getConfig("$(tv)_$INI_CHANNELS") isa AbstractArray || return nothing

            tv = Dict(:id => tvName,
                      :room => room,
                      :ip => getConfig("$(tv)_$INI_TV_IP"),
                      :on_mode => getConfig("$(tv)_$INI_ON_MODE")
                      :channels => getConfig("$(tv)_$INI_CHANNELS"))
        end
    end
    return tv
end




function channelToNumber(channel, channels)

    if channel == nothing || channel == "unknown" || length(channel) < 1
        return 0
    end

    channelNo = findfirst(isequal(channel), channels)

    if channelNo == nothing
        return 0
    end

    return channelNo
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
