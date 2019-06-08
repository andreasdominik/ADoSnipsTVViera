#
# API function goes here, to be called by the
# skill-actions:
#

VIERA_SH = "$(Snips.getAppDir())/Skill/viera.sh"


"""
    switchTVon(ip, mode)

Switch the TV on via a DLNA/uPnP command
(only possible, if the DLNA-server of the TV is running in standby)
or CEC
"""
function switchTVon(ip, mode)

    if ! isOnViera(ip)
        if mode == "upnp"
            runVieraCmd(ip, "standby")
        else  # use cec:
            runVieraCmd(ip, "wakeup")
        end
        sleep(10)
        runVieraCmd(ip, "TV")
    else
        #Snips.publishSay(:already_on)
    end
end

function isOnViera(ip)

    try
        vol = read(`$VIERA_SH $ip getVolume`, String)
        return  occursin(r"<CurrentVolume>[0-9]+</CurrentVolume>", vol)
    catch
        return false
    end
end



function switchTVoff(ip)

    runVieraCmd(ip, "standby")
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





function runVieraCmd(ip, cmd)

    shellcmd = `$VIERA_SH $ip $cmd`
    println("[ADoSnipsTVViera]: VIERA API command: $shellcmd")
    Snips.tryrun(shellcmd, wait = true)
end
