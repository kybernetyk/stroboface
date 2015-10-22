###Kyb's Hue Scripts
These scripts allow you to control your Philips Hue lights from the command line.

##How To
1. Edit 'lights.conf' and set up your bridge IP and secret/username (consult HUE API docs on how to do this)
2. run the scripts

##Dependencies
1. Curl

##Notes
1. The scripts assume you have 4 lights connected to your bridge. If you have less or more lights you will have to hack the scripts.
2. Some scripts (like looping, etc) assume the other scripts are in your $PATH ... so add this to your $PATH because do it

##License
Affero GPL 3 (because fuck you)
