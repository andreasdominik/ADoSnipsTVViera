"""
    triggerTVVieraAction(topic, payload)

The trigger must have the following JSON format:
    {
      "target" : "qnd/trigger/andreasdominik:ADoSnipsTVViera",
      "origin" : "ADoSnipsScheduler",
      "sessionId": "1234567890abcdef",
      "time" : "timeString",
      "trigger" : {
        "room" : "default",
        "device" : "viera",
        "commands" : [ "wakeup", "down", "center"],
        "delay" : 0.5
      }
    }

    Commands will be executed with the api with the
    specified delay in between.
"""
function triggerTVVieraAction(topic, payload)

    println("[ADoSnipsTVViera]: action triggerTVViera() started.")

    # text if trigger is complete:
    #
    payload isa Dict || return false
    haskey( payload, :trigger) || return false
    trigger = payload[:trigger]

    # haskey(trigger, :room) || return false
    haskey(trigger, :device) || return false
    trigger[:device] == "viera" || return false
    haskey(trigger, :commands) || return false
    trigger[:commands] isa AbstractArray || return false

    commands = trigger[:commands]
    delay = haskey(trigger, :delay) ? trigger[:delay] : 1.0

    Snips.isConfigValid(INI_TV_IP) || return false

    for command in trigger[:commands]
        runVieraCmd(Snips.getConfig(INI_TV_IP), command)
        sleep(delay)
    end

    return false
end
