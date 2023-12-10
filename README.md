                                          
              .@         /  ,%       @     
               &,&  ***************,       
                *********/*******,***.     
                **********************     
              &************************,   
        &(&/  &,************************   
      &#&&&&@   *,   ,*****************@   
     %,%&&&(  @@&,######(##***********@    
        @.*//((,//,(&#@ ####*******,&      
           .*/// ####### #####*,%@         
             &,,**(##*,  ##,,              
                  @(*,,**,,**..*.*         
                     @%*******,(******     
                      ,*  (/*///  #%.*@    
                      #/*******//*&        
                        (*. .* **&         
                        @@   #.&@%*/,/(/*(@
                              (/           
                             */.           
                           /.@     

## Whats gazoo:

* A Linux daemon that listens for Deepfield Defender events and speaks what happened (alarms) 
* It can also be used as a tool to decode webhooks sent from Defender
* It can also be configured to do other things, such as send out different rest api calls based on the Defender events it receives

## Licence

* gazoo is Opensource. 
* gazoo uses webhookd as a base, webhookd is also opensource. 

## How does it sound:

* On a Mac I use the "say" command (you will see it used below), this sound really great and is based on siri
* On Ubuntu I use "espeak" command (you will see it used below), this sounds like a 90s arcade game. If you find a better text to speeach you can use it instead below
* On windows 10 I use the "System.Speech.Synthesis.SpeechSynthesizer" command (you will see it used below), this sounds pretty decent, not as nice as Apple siri though 

## Topology 

*The topology could not be much simpler
   
           ############      ############            ###################
           #          #      #          #            #                 #
           # Network  #      # Deefield #            # osx/linux/win10 #
           # Under    # ---> # Defender # -webhook-> # host            #
           # Attack   #      #          #            # running gazoo   #
           #          #      #          #            #                 #
           ############      ############            ###################
     
## installing the code

* if you are not familiar with github, just download the zip from here, https://github.com/sigreen-nokia/gazoo  unzip it locally. Open a terminal
* if you are familiar with github cli then you can use "git clone https://github.com/sigreen-nokia/gazoo.git"

## platforms

* I've tested this on my mac running docker for desktop (for ARM CPU's enable rosseta in advanced settings)
* I've also tested this on Ubuntu Linux 20.04. Install docker using your favorite site 
* I've also tested this on Windows 10 using wsl and docker for desktop 

## pre requisits

* you just need to install Ubuntu's Docker, or on Mac Docker Desktop
* then follow the steps below

## The simplest way to get started: just run my docker image

```
cd gazoo (you much be in the gazoo git)
docker run -d  -v /tmp/gazoo-commands:/tmp/gazoo-commands --restart always --name=gazoo -v ${PWD}/scripts:/scripts -p 8080:8080 simonjohngreen/gazoo
```

## Developer method (if you want to build the docker image yourself)

* This method, allows you the opertunity to customise the scripts. 
* From the git source this builds your own private docker image and then runs it. 
* It doesn't use my image from dockerhub.

```
cd gazoo (you much be in the gazoo git dir) 
docker build --platform=linux/amd64 -t gazoo:1.0 .
docker run -d --restart always --name=gazoo -v /tmp/gazoo-commands:/tmp/gazoo-commands -v ${PWD}/scripts:/scripts -p 8080:8080 gazoo:1.0
```

## playing sounds/speech when Defender events arrive

* you will need a sound card
* for Defender start and stop events gazoo will speak the event and the event id
* for Defender test events (clicking test in the notification ui) gazoo will just say test event
* see scripts/default.sh for how its done
* I use native tools on the host to do the text to speech as containers don't have speakers 

## Configuring MAC OSX host to speak when events arrrive into gazoo

* In a MAC terminal window, copy paste the following
```
cat << EOF > /usr/local/bin/gazoo-speak.sh
#!/bin/bash
tail -f -n0 /tmp/gazoo-commands/streamer | xargs -n1 say
EOF
chmod a+x /usr/local/bin/gazoo-speak.sh
touch /tmp/gazoo-commands/streamer
/usr/local/bin/gazoo-speak.sh &
#this line is suppose to restart the service on powerup, seems to be broken on my mac.
sudo bash
(crontab -l ; echo "@reboot /usr/local/bin/gazoo-speak.sh") | crontab -
exit
```

## Configuring Ubuntu 20.04 host to speak when defender events arrrive into gazoo

* In the Ubuntu terminal, copy paste the following
```
sudo apt install -y espeak-ng-espeak
sudo bash -c 'cat << EOF > /usr/local/sbin/gazoo-speak.sh
#!/bin/bash
tail -f -n0 /tmp/gazoo-commands/streamer | espeak 
EOF'
sudo chmod a+x /usr/local/sbin/gazoo-speak.sh
sudo touch /tmp/gazoo-commands/streamer
sudo chmod -R 777 /tmp/gazoo-commands/
/usr/local/sbin/gazoo-speak.sh &
(crontab -l ; echo "@reboot /usr/local/sbin/gazoo-speak.sh") | crontab -
```

## Configuring Windows 10 to speak when defender events arrrive into gazoo
* Install wsl 2 for linux
* usually the install is just powershell "wsl --install" but check with microsoft
* Install docker desktop for windows and configure wsl integration into ubuntu https://docs.docker.com/desktop/wsl/
* git clone gazoo inside your wsl window, cd into it and run the docker (use any method shown above will work)
* Copy paste the following into your ubuntu wsl window to make it speak the Defender events the docker sees
```
sudo bash -c "cat << 'EOF' > /usr/local/sbin/gazoo-speak.sh
#!/bin/bash
tail -f -n0 /tmp/gazoo-commands/streamer | { while [ 1 ]; do read SPEECH; export COMMAND=\"powershell.exe 'Add-Type -AssemblyName System.speech;(New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak(\\\"\$SPEECH\\\")'\"; eval "\$COMMAND"; done; }
EOF"
sudo chmod a+x /usr/local/sbin/gazoo-speak.sh
sudo touch /tmp/gazoo-commands/streamer
sudo chmod -R 777 /tmp/gazoo-commands/
/usr/local/sbin/gazoo-speak.sh &
(crontab -l ; echo "@reboot /usr/local/sbin/gazoo-speak.sh") | crontab -
```

## Configuring your defender notification in the Deepfield ui

* The assumption is that you have port 8080 opened up all the way to the docker
*       In the defender ui
*       Defender->notification->[add]
*       name gazoo
*       tick webhook
*       url: http://[your docker hosts ip or fqdn]:8080
*       click test, you should see a green test sent successfully if your firewall and docker allow the 8080 port traffic
*       start and end event should be ticked, this is the default
*       save
*       Then add the notification to the policy

## Configuring gazoo to act as a webhook decoder (message analyser)

* edit file scripts/default.txt, hash out the block of text that starts with 
* "#if you want to see the webhook contents decoded hash out this block" 
* Then stop start the docker (no need to build or remove it) and it will pickup the new default.txt
* now on the host "tail -f /tmp/gazoo-commands/streamer" to see the decoded webhooks 
* example output follows:
```
DEBUG: default.sh was ran as the webhook url ended in a /
DEBUG: Hook information: hook_name=default.sh, hook_id=3, hook_method=POST
DEBUG: Hook information: x_forwarded_for=172.17.0.1, x_webauth_user=
DEBUG: Query parameter: Status=
DEBUG: Header parameter: user-agent=python-requests/2.27.1
DEBUG: JSON data block decoded:
{
  "Event ID": 27,
  "Event Console": "https://exp-e-upgrade-testing-vlabs.deepfield.net/defender/events/27",
  "Status": "ACTIVE",
  "Start": "2023-12-02 22:41:11.000000 UTC",
  "End": "-",
  "Policy ID": 1,
  "Policy Name": "vlabs_default",
  "Dimension ID": 192,
  "Dimension Name": "Customer",
  "Dimension Configuration": "https://exp-e-upgrade-testing-vlabs.deepfield.net/config/dimensions/192",
  "Protected Object ID": 7,
  "Protected Object Name": "96.0.0.0/4",
  "Protected Object Defender Console": "https://exp-e-upgrade-testing-vlabs.deepfield.net/defender/policies/1/7",
  "Protected Object Configuration": "https://exp-e-upgrade-testing-vlabs.deepfield.net/config/dimensions/192/7",
  "Threshold": "DDoS directed at host exceeds 60.00 kpps",
  "Threshold Exceeded": "2023-12-02 22:41:11.000000 UTC",
  "Threshold Inactive": "-",
  "Peak DDoS PPS": 65763,
  "Peak DDoS BPS": 56600160,
  "DDoS Types": "tcpreflection, wsd, botnet, arms, dns",
  "Top Destinations by DDoS+Dropped BPS": {
    "columns": [
      "Addr",
      "Peak DDoS+Dropped BPS"
    ],
    "rows": [
      [
        "100.100.100.214",
        56590560.0
      ],
      [
        "100.100.100.73",
        5333.0
      ],
      [
        "100.100.100.58",
        1066.0
      ],
      [
        "100.100.100.64",
        1066.0
      ],
      [
        "100.100.100.65",
        1066.0
      ],
      [
        "100.100.100.75",
        1066.0
      ]
    ]
  },
  "Top Destinations by DDoS+Dropped PPS": {
    "columns": [
      "Addr",
      "Peak DDoS+Dropped PPS"
    ],
    "rows": [
      [
        "100.100.100.214",
        65733.0
      ],
      [
        "100.100.100.73",
        16.0
      ],
      [
        "100.100.100.58",
        3.0
      ],
      [
        "100.100.100.64",
        3.0
      ],
      [
        "100.100.100.65",
        3.0
      ],
      [
        "100.100.100.75",
        3.0
      ]
    ]
  }
}
```


## see notes.txt for debug hints and more detailed instructions

