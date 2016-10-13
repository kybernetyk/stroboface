require 'net/http'
require 'json'
require_relative 'config.rb'

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
		if Config.verbosity_level > 0
			print "sending: "
			puts jpl
		end

		endpoints = OpenStruct.new
		endpoints.light = "/api/#{Config.api_key}/lights/#{@light_id}/state"
		endpoints.group = "/api/#{Config.api_key}/groups/#{@light_id}/action"

		if self.is_group
			endp = endpoints.group
		else
			endp = endpoints.light
		end
		
		http = Net::HTTP.new(Config.ip, Config.port)
		resp = http.send_request('PUT', endp, jpl)
		
		if Config.verbosity_level > 0
			print "response: "
			puts resp.body
		end
	end
end

