                                          
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
* it can also be configured to do other things, such as send out different rest api calls based on the Defender events it receives

## Licence

* gazoo is Opensource. 
* gazoo uses webhookd as a base, webhookd is also opensource. 

## installing the code

* if you are not familiar with github, just download the zip from here, https://github.com/sigreen-nokia/gazoo  unzip it locally. Open a terminal
* if you are familiar with github cli then you can use "gh repo clone sigreen-nokia/gazoo" or "git clone sigreen-nokia/gazoo"

## platforms

* I've tested this on my mac running docker for desktop
* I've also tested this on ubuntu-linx(20.04) running docker
* It will probably also work on a windows 10 machine with wsl installed (ubuntu image), using the wsl linux terminal to run it.

## pre requisits

* you just need to install docker or on mac docker desktop
* then follow the steps below

## The simplest way to get started: just run my docker image

```
docker run -d  -v /tmp/gazoo-commands:/tmp/gazoo-commands --restart always --name=gazoo -v ${PWD}/scripts:/scripts -p 8080:8080 simonjohngreen/gazoo
```

## Developer method (build)

* This method, allows you the opertunity to customise the scripts. 
* From the git source this builds your own private docker image and then runs it. 
* It doesn't use my image from dockerhub.

```
docker build -t gazoo:1.0 .
docker run -d --restart always --name=gazoo -v /tmp/gazoo-commands:/tmp/gazoo-commands -v ${PWD}/scripts:/scripts -p 8080:8080 gazoo:1.0
```

## playing sounds/speech when Defender events arrive

* for Defender start and stop events gazoo will speak the event and the event id
* for Defender test events (clicking test in the notification ui) gazoo will just say test event
* see scripts/default.sh for how its done
* I use native tools on the host to do the text to speech as containers don't have speakers 

## Configuring a  MAC OSX host to speak when events arrrive into gazoo

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

## (In progress) Configuring an Ubuntu 20.04 host to speak when defender events arrrive into gazoo

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


## see notes.txt for debug hints and more detailed instructions

