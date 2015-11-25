###Kyb's Hue Scripts
These scripts allow you to control your Philips Hue lights from the command line.

##How To
1. Edit 'lights.conf' and set up your bridge IP and secret/username (consult [HUE API docs](http://www.developers.meethue.com/documentation/getting-started) on how to do this)
2. run the scripts

##How do I find my bridge IP?
Go to the bridgefinder directory, execute build.sh and run bridgefinder binary. Depends on clang and libdispatch (OS X with devtools installed essentially).

##Dependencies
1. Curl

##Notes
1. The scripts assume you have 4 lights connected to your bridge. If you have less or more lights you will have to hack the scripts.
2. Some scripts (like looping, etc) assume the other scripts are in your $PATH ... so add this to your $PATH because do it
3. Yes, my secret key is in the lights.conf but fuck you I'm too lazy to change it every time I commit. Come and haxx0r my lights ...

##License
Affero GPL 3 (because fuck you)
