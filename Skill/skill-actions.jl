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
    Snips.printLog("action switchOnOffActions() started.")

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
    Snips.isValidOrEnd(tv, errorMsg = :no_tv_in_room) || return true

    # println(">>> $onOrOff, $device")
    if device == "TV"
        # check, if all config.ini entries are in correct:
        #
        channel = Snips.extractSlotValue(payload, SLOT_CHANNEL)
        channelNo = channelToNumber(channel, tv[:channels])

        if onOrOff == "ON"
            stopListen()
            # Snips.publishSay(:not_listen)
            Snips.publishEndSession(:switchon)
            switchTVon(tv, tv[:on_mode])

            if channelNo > 0
                sleep(2)
                switchTVChannel(tv[:ip], channelNo)
            end
        else
            if isOnViera(tv)
                Snips.publishEndSession(:switchoff)
                switchTVoff(tv)
            else
                Snips.publishEndSession(:tv_is_off)
            end
        end

    elseif device == "volume"
        if !isOnViera(tv)
            Snips.publishEndSession(:tv_is_off)
            return true
        end

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
    Snips.printLogln("action switchChannelAction() started.")

    # continue only, if a tv in room:
    #
    tv = getMatchedTv(payload)
    Snips.isValidOrEnd(tv, errorMsg = :no_tv_in_room) || return true
    if !isOnViera(tv)
        Snips.publishEndSession(:tv_is_off)
        return true
    end


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
    Snips.printLogln("action pauseAction() started.")

    tv = getMatchedTv(payload)
    Snips.isValidOrEnd(tv, errorMsg = :no_tv_in_room) || return true
    if !isOnViera(tv)
        Snips.publishEndSession(:tv_is_off)
        return true
    end

    pause = Snips.extractSlotValue(payload, SLOT_PAUSE)

    if pause != nothing && pause in ["play", "pause"]

        if pause == "play"
            stopListen()
            # Snips.publishSay(:not_listen)
            Snips.publishEndSession(:ok)
            pausePlayTV(tv[:ip])
            return false
        else # pause == "pause"
            Snips.publishEndSession(:ok)
            pausePauseTV(tv[:ip])
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

    Snips.isConfigValid(INI_TV_LIST) || return nothing
    if Snips.getConfig(INI_TV_LIST) isa AbstractString
        tvs = [Snips.getConfig(INI_TV_LIST)]
    else
        tvs = Snips.getConfig(INI_TV_LIST)
    end

    for tvName in tvs
        tvRoomName = "$(tvName):$INI_TV_ROOM"
        Snips.isConfigValid(tvRoomName) || return nothing
        if Snips.getConfig(tvRoomName) == room
            Snips.isConfigValid("$(tvName):$INI_TV_IP") || return nothing
            Snips.isConfigValid("$(tvName):$INI_ON_MODE") || return nothing
            Snips.getConfig("$(tvName):$INI_CHANNELS") isa AbstractArray || return nothing

            tv = Dict(:id => tvName,
                      :room => room,
                      :ip => Snips.getConfig("$(tvName):$INI_TV_IP"),
                      :on_mode => Snips.getConfig("$(tvName):$INI_ON_MODE"),
                      :channels => Snips.getConfig("$(tvName):$INI_CHANNELS"))
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
