#!/bin/bash

#test script to teach you the parameters the daemon can pass back
echo "Hook information: hook_name=$hook_name, hook_id=$hook_id, hook_method=$hook_method"
echo "Hook information: x_forwarded_for=$x_forwarded_for, x_webauth_user=$x_webauth_user"
echo "Query parameter: id=$id"
echo "Header parameter: user-agent=$user_agent"
echo "Script parameters: $1"

