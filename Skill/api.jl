#
# API function goes here, to be called by the
# skill-actions:
#

VIERA_SH = "$(Snips.getAppDir())/Skill/viera.sh"


function switchTVon(ip, gpio)

    Snips.setGPIO(gpio, :on)
    sleep(4)
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

    runVieraCmd(ip, )


function runVieraCmd(ip, cmd)

    shellcmd = `$VIERA_SH $ip $cmd`
    snips.tryrun(shellcmd, wait = true)
end
