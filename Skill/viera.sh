#!/bin/bash
#
# API for HTML interface to Panasonic Viera TV.
#
# package cec-utils must be installed!
# and is used for poweron from standby.
#
#
# enable debugging:
#
if [[ ($1 == "-h") ]] || [[ ($# -lt 1) ]] ; then
  cat <<ENDHELP
  Remote control of Panasonic Viera TVs via uPnP.
  wakeup is implemented using CEC.

  usage: viera.sh <--debug> 192.168.0.1 command

  The following commands are supported:
  Volume control:
    getVolume
    setVolume value
    mute
    unMute
    getMute
  Numbers:
    0-9
  Source:
    TV
    AV
  Arrow navigation:
    right
    left
    up
    down
    center
    return
    exit
  Other:
    vieraLink
    epg
    info
  Pause/resume:
    play
    pause
  Only poweroff possible by DLNA (because TV is not listening in standby mode):
  wakeup/poweron is implemented via CEC.
    standby
    wakeup (wake up by CEC "on 0")
    susi (wakeup by CEC "as" on HDMI4)
  waits (in sec):
    wait1
    wait10
    wait20
ENDHELP
  exit 1
fi

if [[ "$1" == "--debug" ]] ; then
  set -x
  set -v
  V="-v"  #"--trace-ascii"
  shift
else
  V=""
fi

CURL_ARGS=""

# WAKE_UP_CMD="echo 'on 0' | cec-client -s -d 1"
TV_IP=$1
CMD=$2
VALUE=$3

# define URLs for both modes:
# and set default to command mode:
#
# TV_IP="192.168.42.151"
TV_PORT="55000"
TIMEOUT=1

URL_RENDER="/dmr/control_0"
URN_RENDER="urn:schemas-upnp-org:service:RenderingControl:1"

URL_CMD="/nrc/control_0"
URN_CMD="urn:panasonic-com:service:p00NetworkControl:1"

URL=$URL_CMD
URN=$URN_CMD
ACTION="X_SendKey"

# switch commands (render or command mode):
#
case "$CMD" in
  susi)
    echo "as" | cec-client -s -d 1
    exit $?
    ;;
  wakeup)
    echo "on 0" | cec-client -s -d 1
    exit $?
    ;;
  wait20)
    sleep 20
    exit $?
    ;;
  wait10)
    sleep 10
    exit $?
    ;;
  wait1)
    sleep 1
    exit $?
    ;;
  listPresets)
    ACTION="ListPresets"
    COMMAND="<InstanceID>0</InstanceID><Channel>Master</Channel>"
    URL=$URL_RENDER
    URN=$URN_RENDER
    ;;
  getVolume)
    ACTION="GetVolume"
    COMMAND="<InstanceID>0</InstanceID><Channel>Master</Channel>"
    URL=$URL_RENDER
    URN=$URN_RENDER
    CURL_ARGS="--connect-timeout 1"
    ;;
  setVolume)
    ACTION="SetVolume"
    URL=$URL_RENDER
    URN=$URN_RENDER
    COMMAND="<InstanceID>0</InstanceID>
             <Channel>Master</Channel>
             <DesiredVolume>${VALUE}</DesiredVolume>"
    ;;
  mute)
    ACTION="SetMute"
    COMMAND="<InstanceID>0</InstanceID>
             <Channel>Master</Channel>
             <DesiredMute>1</DesiredMute>"
    URL=$URL_RENDER
    URN=$URN_RENDER
    ;;
  unMute)
    ACTION="SetMute"
    COMMAND="<InstanceID>0</InstanceID>
             <Channel>Master</Channel>
             <DesiredMute>0</DesiredMute>"
    URL=$URL_RENDER
    URN=$URN_RENDER
    ;;
  getMute)
    ACTION="GetMute"
    COMMAND="<InstanceID>0</InstanceID>
             <Channel>Master</Channel>"
    URL=$URL_RENDER
    URN=$URN_RENDER
    ;;
  getInputMode)
    ACTION="X_GetInputMode"
    COMMAND="<X_InputMode>"0"</X_InputMode>"
    ;;
  sendString)
    ACTION="X_SendString"
    COMMAND="<X_String>""</X_String>"
    ;;
  [0-9])
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_D${CMD}-ONOFF</X_KeyEvent>"
    ;;
  TV)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_TV-ONOFF</X_KeyEvent>"
    ;;
  AV)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_CHG_INPUT-ONOFF</X_KeyEvent>"
    ;;
  right)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_RIGHT-ONOFF</X_KeyEvent>"
    ;;
  left)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_LEFT-ONOFF</X_KeyEvent>"
    ;;
  up)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_UP-ONOFF</X_KeyEvent>"
    ;;
  down)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_DOWN-ONOFF</X_KeyEvent>"
    ;;
  center)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_ENTER-ONOFF</X_KeyEvent>"
    ;;
  return)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_RETURN-ONOFF</X_KeyEvent>"
    ;;
  exit)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_CANCEL-ONOFF</X_KeyEvent>"
    ;;
  vieraLink)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_VIERA_LINK-ONOFF</X_KeyEvent>"
    ;;
  epg)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_EPG-ONOFF</X_KeyEvent>"
    ;;
  info)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_INFO-ONOFF</X_KeyEvent>"
    ;;
  play)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_PLAY-ONOFF</X_KeyEvent>"
    ;;
  pause)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_PAUSE-ONOFF</X_KeyEvent>"
    ;;
  standby)
    ACTION="X_SendKey"
    COMMAND="<X_KeyEvent>NRC_POWER-ONOFF</X_KeyEvent>"
    ;;
  *)
    echo "Command \"$CMD\" is not supported!"
    echo " "
    exit 1
    ;;
esac

# define HTML content:
#
CONTENT="<?xml version=\"1.0\" encoding=\"utf-8\"?>
<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
    <s:Body>
        <u:${ACTION} xmlns:u=\"${URN}\">
            ${COMMAND}
        </u:${ACTION}>
    </s:Body>
</s:Envelope>"


echo $CONTENT
echo " "

CONTENT_LEN=${#CONTENT}

HEADER_1="Content-Length: ${CONTENT_LEN}"
HEADER_2="Content-Type: text/xml; charset=\"utf-8\""
HEADER_3="SOAPACTION: \"${URN}#${ACTION}\""

echo $HEADER_1
echo $HEADER_2
echo $HEADER_3


curl ${V} --connect-timeout $TIMEOUT \
     ${CURL_ARGS} -X POST -d "$CONTENT" http://${TV_IP}:${TV_PORT}$URL \
     --header "$HEADER_1" --header "$HEADER_2" --header "$HEADER_3"

exit $?  # return curl exit status
