#!/bin/bash
#this is the script that will be hit for defender events

#if you want to see the webhook contents decoded hash out this block
#the output goes to file /tmp/gazoo-commands/message-decode
#to watch it on the host "tail -f /tmp/gazoo-commands/message-decode"
#
#echo "DEBUG: default.sh was ran as the webhook url ended in a /" >> /tmp/gazoo-commands/message-decode
#echo "DEBUG: Hook information: hook_name=$hook_name, hook_id=$hook_id, hook_method=$hook_method" >> /tmp/gazoo-commands/message-decode
#echo "DEBUG: Hook information: x_forwarded_for=$x_forwarded_for, x_webauth_user=$x_webauth_user" >> /tmp/gazoo-commands/message-decode
#echo "DEBUG: Query parameter: Status=$Status" >> /tmp/gazoo-commands/message-decode
#echo "DEBUG: Header parameter: user-agent=$user_agent" >> /tmp/gazoo-commands/message-decode
#echo "DEBUG: JSON data block decoded:" >> /tmp/gazoo-commands/message-decode
#echo "$1" | jq . >> /tmp/gazoo-commands/message-decode

#extract the event and the event id from the JSON data block
#note we are dealing with a bug here, for the test message .status for everything else .Status
STATUS=`sed -e 's/^"//' -e 's/"$//' <<< $(jq '.Status' <<< "$1")` 
EVENTID=`sed -e 's/^"//' -e 's/"$//' <<< $(jq '."Event ID"' <<< "$1")` 
#echo "DEBUG: STATUS is: $STATUS" >> /tmp/gazoo-commands/streamer
#echo "DEBUG: EVENTID is: $EVENTID" >> /tmp/gazoo-commands/streamer


#this block handles the event to speech
#
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

