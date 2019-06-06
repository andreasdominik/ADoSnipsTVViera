#
# API function goes here, to be called by the
# skill-actions:
#

VIERA_SH = "$(Snips.getAppDir())/Skill/viera.sh"


"""
    switchTVonGPIO(ip, gpio)

Switch the TV on via power on by GPIO
"""
function switchTVonGPIO(ip, gpio)

    Snips.setGPIO(gpio, :on)
    sleep(4)
    runVieraCmd(ip, "TV")
end



"""
    switchTVonDLNA(ip)

Switch the TV on via a DLNA/uPnP command
(only possible, if the DLNA-server of the TV is running in standby)
"""
function switchTVonDLNA(ip)

    runVieraCmd(ip, "powerOff")
    runVieraCmd(ip, "TV")
end


"""
    switchTVonKODI(ip, gpio)

Switch the TV on via power on of a connected KODI/libreElec device.
"""
function switchTVonKODI(ip, gpio)

    Snips.setGPIO(gpio, :on)
    sleep(5)
    runVieraCmd(ip, "TV")
end


function switchTVoff(ip, gpio)

    runVieraCmd(ip, "powerOff")
    sleep(4)
    Snips.setGPIO(gpio, :off)
end


function switchTVChannel(ip, ch)

    for i in reverse(digits(channel))
        runVieraCmd(ip, i)
        sleep(0.5)
    end
end

function muteTV(ip)

    runVieraCmd(ip, "mute")
end


function umuteTV(ip)

    runVieraCmd(ip, "unMute")
end


function pauseResumeTV(ip)

    runVieraCmd(ip, "pause")
end





function runVieraCmd(ip, cmd)

    shellcmd = `$VIERA_SH $ip $cmd`
    snips.tryrun(shellcmd, wait = true)
end
