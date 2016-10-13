###Stroboface - Command Line Hue Scripts
These scripts allow you to control your Philips Hue lights from the command line without the need for the over engineered Philips SDK.

##New: Ruby Version
I'm porting the scripts to Ruby right now. The most important stuff has been ported already. (Just learned Ruby 5 hours ago - so please excuse the bad code).

##How To
1. Edit 'stroboface.conf.rb' (or lights.conf for the shell version) and set up your bridge IP and secret/username (consult [HUE API docs](http://www.developers.meethue.com/documentation/getting-started) on how to do this)
2. run the scripts

##How do I find my bridge IP?
Go to the bridgefinder directory, execute build.sh and run bridgefinder binary. Depends on clang and libdispatch (OS X with devtools installed essentially). Builds and runs on linux (use build-rpi.sh) but the Raspberry Pi seems to be too shit to receive udp multicast messages. My other Debian box works without problems. Meh ... I guess you get what you pay for, eh?

##Dependencies
1. Curl

##Notes
1. The scripts assume you have 4 lights connected to your bridge. If you have less or more lights you will have to hack the scripts.
2. Some scripts (like looping, etc) assume the other scripts are in your $PATH ... so add this to your $PATH because do it
3. Yes, my secret key is in the lights.conf. Come and haxx0r my lights ...

##License
Affero GPL 3
