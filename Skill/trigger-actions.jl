"""
    triggerTVVieraAction(topic, payload)

The trigger must have the following JSON format:
    {
      "target" : "qnd/trigger/andreasdominik:ADoSnipsTVViera",
      "origin" : "ADoSnipsScheduler",
      "sessionId": "1234567890abcdef",
      "siteId" : "default",
      "time" : "timeString",
      "trigger" : {
        "room" : "default",
        "device" : "plasma",
        "commands" : [ "wakeup", "down", "center"],
        "delay" : 0.5
      }
    }

    "device" is the unique device-ID, defined in the config.ini.

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

    #haskey(trigger, :room) || return false
    haskey(trigger, :device) || return false
    device = trigger[:device]

    haskey(trigger, :commands) || return false
    trigger[:commands] isa AbstractArray || return false
    commands = trigger[:commands]

    delay = haskey(trigger, :delay) ? trigger[:delay] : 1.0

    # get device params from config.ini:
    #
    Snips.isConfigValid("$(device)_$(INI_TV_IP)") || return false
    ip = Snips.getConfig("$(device)_$(INI_TV_IP)")

    for command in commands
        runVieraCmd(ip, command)
        sleep(delay)
    end

    return false
end
