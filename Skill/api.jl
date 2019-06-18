#
# API function goes here, to be called by the
# skill-actions:
#

VIERA_SH = "$(Snips.getAppDir())/Skill/viera.sh"


"""
    switchTVon(tv, mode)

Switch the TV on via a DLNA/uPnP command
(only possible, if the DLNA-server of the TV is running in standby)
or CEC
"""
function switchTVon(tv, mode)

    if ! isOnViera(tv)
        if mode == "upnp"
            runVieraCmd(tv[:ip], "standby")
        else  # use cec:
            runVieraCmd(tv[:ip], "susi")
        end
        sleep(10)
        runVieraCmd(tv[:ip], "TV")
    else
        #Snips.publishSay(:already_on)
    end
end

function isOnViera(tv)

    # try
    #     vol = read(`$VIERA_SH $ip getVolume`, String)
    #     return  occursin(r"<CurrentVolume>[0-9]+</CurrentVolume>", vol)
    # catch
    #     return false
    # end
    return Snips.ping(tv[:ip])
end



function switchTVoff(tv)

    if isOnViera(tv)
        runVieraCmd(tv[:ip], "standby")
    end
end


function switchTVChannel(ip, ch)

    for i in reverse(digits(ch))
        runVieraCmd(ip, i)
        sleep(0.5)
    end
end

function muteTV(ip)

    runVieraCmd(ip, "mute")
end


function unmuteTV(ip)

    runVieraCmd(ip, "unMute")
end


function pausePauseTV(ip)

    runVieraCmd(ip, "pause")
end


function pausePlayTV(ip)

    runVieraCmd(ip, "play")
end





function runVieraCmd(ip, cmd; silent = false)

    shellcmd = `$VIERA_SH $ip $cmd`
    println("[ADoSnipsTVViera]: VIERA API command: $shellcmd")
    Snips.tryrun(shellcmd, wait = true, silent = silent)
end
