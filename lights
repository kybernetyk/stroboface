#!/usr/bin/env ruby
require 'optparse'
require_relative 'stroboface.rb'

options = {
	:light_id => 0
}

#i never bothered with correct command line argument parsing before. but because
#ruby is like poetry I have changed my mind.
opt_parser = OptionParser.new do |opts|
	opts.version = "alpha ultra tournament edition advanced turbo version 1.0"
	opts.banner = "Usage: #{opts.program_name()} [options] <command> [command_value]"
	opts.separator "    (c) 2016 kyb. All Rights Reversed. License is AFFERO_GPL_3."
	opts.separator ""
  
	opts.separator "Commands:"
	opts.separator "    on                               Let there be light."
	opts.separator "    off                              Lights out."
	opts.separator "    hue <0-65000>                    Adjust Hue."
	opts.separator "    bri <0-255>                      Adjust Brightness."
	opts.separator "    scan                             Scan for available bridges. Requires bridgefinder."

	opts.separator ""
	opts.separator "Options:"
	opts.on('-l', '--light ID', "Send commands to specific light. 0 = all lights. (0 is default)") { |v| options[:light_id] = v.to_i }
	opts.on('-t', '--trans TIME', "Transition duration in Dutch seconds.") { |v| Config.trans_time = v.to_i }
	opts.on('-v', '--verbose', "Verbosity level. Show irrelevant debug information.") { |v| Config.verbosity_level = 3 }
end
opt_parser.parse!

#dumb user is dumb
if ARGV.count == 0
	puts opt_parser
	exit
end

#try to fire up our external utility
if ARGV[0].downcase == "scan"
	exec("#{File.dirname(__FILE__)}/bridgefinder/bridgefinder")
end

#ok, let's get started...
hue = Stroboface.new(options[:light_id])
is_complex_command = (ARGV.count >= 2)

if is_complex_command
	cmd = ARGV[0].downcase
	message = "#{cmd}="
	value = ARGV[1].to_i

	#tries to call hue.message(value) ... like objc_send()	
	hue.send(message, value)
else
	cmd = ARGV[0].downcase

	#heh
	if cmd == "on" or cmd == "off"
		cmd = "turn_#{cmd}"
	end
	
	hue.send(cmd)
end

#TODO: when send() fails try to forward to lights_#{cmd} shell scripts

