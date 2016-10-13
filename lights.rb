#!/usr/bin/env ruby
require_relative 'hue.rb'

if ARGV.count == 0
	puts "syntax: lights <command> [command_value] [trans_time]"
	puts "understood commands:"
	puts "\tturn_on (alias: on)"
	puts "\tturn_off (alias: off)"
	puts "\tbri <0-255>"
	puts "\thue <0-65000>"
	exit 1
end

hue = Hue.new(0)

is_complex_command = (ARGV.count >= 2)
has_trans_time = (ARGV.count >= 3)

if is_complex_command
	cmd = ARGV[0].downcase
	message = "#{cmd}="
	value = ARGV[1].to_i

	if has_trans_time
		ttime = ARGV[2].to_i
		hue.trans_time = ttime
	end

	hue.send(message, value)
else
	cmd = ARGV[0].downcase
	if cmd == "on" or cmd == "off"
		cmd = "turn_#{cmd}"
	end

	hue.send(cmd)
end

