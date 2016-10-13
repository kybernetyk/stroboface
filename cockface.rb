#
# cockface.rb - access your philips hue without the AIDS that's their official SDK
# 
# the name is dedicated to the philips hue development team. thanks for nothing.
#
# Licensed under Affero GPL 3 because I hate people and want you all to suffer. 
#
# Don't contact me. Don't send me patches. Kthxbye.
#

require 'net/http'
require 'json'
require_relative 'cockface.config.rb'

# 
# ok, let's face it. we actually could have nice things. if it weren't for 
# greedy and incompetent asswipes like philips.
#
# i have stopped buying their shitty lights because at some point in time
# they decided to retroactively limit what the hue can do. 
#
# before you could have nice seizure inducing strobo effects. it was also 
# possible to build your own ghetto "ambilight" knock-off to fill the room 
# with nice orange tones whenever you decided to visit pornhub.
#
# but then philips decided to act and issued firmware 'updates' which
# disabled all cool features on the hue. now all you can do is change
# the lights in your room with your phone.
#
# oh no, wait. you can't. for that you need to buy their newest bridge
# because the old one obviously isn't able to receive an actually useful
# firmware update.
#
# so stop buying those shitty hues. they are overpriced for what they can't do.
#
# oh and if there was a hell for bad software developers it would be run by
# philips' dev department. honestly who the fuck came up with that atrocious
# SDK? if I ever wanted to code against overengineered enterprise SDKs 
# written by Java savants I'd ... oh wait ... no I'd never want that. 
#
# so why do I have to put up with that shit when I want to turn on my $200 
# light bulb via my computer?!
#
# honestly philips ...
#
# JUST LOOK AT WHAT I HACKED TOGETHER IN 3 FUCKING HOURS! WHY IS THIS SCRIPT
# SHORTER THAN THE INTRODUCTION PARAGRAPH FOR YOUR SDK DOCS PHILIPS?! WHY?!
#
# *mic drop*
#
#

class Cockface 
	#if light_id is == 0 then this will talk to all lights!
	def initialize(light_id)
		@light_id = light_id
		@trans_time = Config.trans_time
	end

	attr_accessor :trans_time

	def is_group()
		return @light_id == 0
	end

	def turn_on()
		pl = {"on" => true}
		self.send_request(pl, 0)
	end

	def turn_off()
		pl = {"on" => false}
		self.send_request(pl, 0)
	end


	def hue=(hval)
		pl = {"hue" => hval}
		self.send_request(pl, @trans_time)
	end

	def bri=(hval)
		pl = {"bri" => hval}
		self.send_request(pl, @trans_time)
	end


	def send_request(payload, trans_time)
		payload['transitiontime'] = trans_time 
		jpl = payload.to_json
		
		endpoints = OpenStruct.new
		endpoints.light = "/api/#{Config.api_key}/lights/#{@light_id}/state"
		endpoints.group = "/api/#{Config.api_key}/groups/#{@light_id}/action"

		if self.is_group
			endp = endpoints.group
		else
			endp = endpoints.light
		end
	
		if Config.verbosity_level > 0
			print "url: "
			puts endp
			print "payload: "
			puts jpl
		end

	
		http = Net::HTTP.new(Config.ip, Config.port)
		resp = http.send_request('PUT', endp, jpl)
		
		if Config.verbosity_level > 0
			print "response: "
			puts resp.body
		end
	end
end

