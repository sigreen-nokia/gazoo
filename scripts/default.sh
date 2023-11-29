#!/bin/bash
#this is the script that will be hit for defender events

#these lines are usefull for debugging
#echo "DEBUG: default.sh was ran as the url ended in a /"
#echo "DEBUG: Hook information: hook_name=$hook_name, hook_id=$hook_id, hook_method=$hook_method"
#echo "DEBUG: Hook information: x_forwarded_for=$x_forwarded_for, x_webauth_user=$x_webauth_user"
#echo "DEBUG: Query parameter: Status=$Status"
#echo "DEBUG: Header parameter: user-agent=$user_agent"
#echo "DEBUG: Script parameters: $1" >> /tmp/gazoo-commands/streamer

#extract the event and the event id from the JSON data block
#note we are dealing with a bug here, for the test message .status for everything else .Status
STATUS=`sed -e 's/^"//' -e 's/"$//' <<< $(jq '.Status' <<< "$1")` 
EVENTID=`sed -e 's/^"//' -e 's/"$//' <<< $(jq '."Event ID"' <<< "$1")` 
#echo "DEBUG: STATUS is: $STATUS" >> /tmp/gazoo-commands/streamer
#echo "DEBUG: EVENTID is: $EVENTID" >> /tmp/gazoo-commands/streamer

#Based on the event echo details into the shared file to play on the host
#note here you could also use curl instead here, to send a rest api out to another platform rather than play sounds 
#

case "$STATUS" in
  "ACTIVE")
    echo "Defender Start event $EVENTID" >> /tmp/gazoo-commands/streamer
    ;;

  "FINISHED")
    echo "Defender Stop event $EVENTID" >> /tmp/gazoo-commands/streamer
    ;;

  *)
    #test events uses .status not .Status, seems like a bug but lets handle that
    if [ "$STATUS" = "null" ]; then
        TESTSTATUS=`sed -e 's/^"//' -e 's/"$//' <<< $(jq '.status' <<< "$1")` 
        #echo "DEBUG: TESTSTATUS is: $TESTSTATUS" >> /tmp/gazoo-commands/streamer
        if [ "$TESTSTATUS" = "TEST" ]; then
            echo "Defender Test event" >> /tmp/gazoo-commands/streamer
        else
            echo "Defender unrecognised event" >> /tmp/gazoo-commands/streamer
        fi    
    fi
    ;;
esac

