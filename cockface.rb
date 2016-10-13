#
# cockface.rb - access your philips hue without the AIDS that's their official SDK
# 
# the name is dedicated to the philips hue development team. thanks for blocking strobo, fuckers.
#
# Licensed under Affero GPL 3 because I hate people and want you to suffer. 
#
# Don't contact me. Don't send me patches. Kthxbye.
#

require 'net/http'
require 'json'
require_relative 'cockface.config.rb'

class Hue

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

