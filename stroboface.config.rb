#
# default configs
#
# Philips is the reason why we can't have nice things.
#

class Config
	#change this to your liking
	@ip = "192.168.0.52"
	@port = 80
	@light_count = 5
	@api_key = "2c94da63e6702cf1c368f5b30235a47"
	@trans_time = 15
	@verbosity_level = 0

	#don't change below this line
	class << self
		attr_accessor :ip, :port, :light_count, :api_key, :trans_time
		attr_accessor :verbosity_level
	end
end
