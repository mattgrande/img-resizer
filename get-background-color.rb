#!/usr/bin/env ruby

require 'optparse'
require File.join(File.dirname(__FILE__), 'classes', 'get-outside-colors.rb')

options = { :file_name  => nil }
optparse = OptionParser.new do |opts|
	opts.banner = 'Usage: get-background-color.rb [options]'

	opts.on('-f [file name]', '--filename [file name]', 'The file name of the image to be resized') do |fn|
		if !File.exists? fn
			puts "File #{fn} does not exist"
			exit
		end
		if !File.readable? fn
			puts "File #{fn} is not readable"
			exit
		end
		options[:file_name] = fn
	end

	opts.on('-?', '--help', 'Display this screen') do
		puts opts
		exit
	end
end

begin
  optparse.parse!
  mandatory = [:file_name]                                         # Enforce the presence of
  missing = mandatory.select{ |param| options[param].nil? }        # the -f switch
  if not missing.empty?                                            #
    puts "Missing options: #{missing.join(', ')}"                  #
    puts optparse                                                  #
    exit                                                           #
  end                                                              #
rescue OptionParser::InvalidOption, OptionParser::MissingArgument  #
end

image = ChunkyPNG::Image.from_file( options[:file_name] )
common_colors = GetOutsideColors.new
colors = common_colors.get_color( image, 1 )
bg_color = ChunkyPNG::Color.to_hex( colors.keys[0] )

# If the colour is not at all transparent (eg, hex colour ends with ff),
# remove the 'Alpha' part of the image. (From #2f7ee9ff to #2f7ee9)
if bg_color.length == 9 and bg_color.end_with? 'ff'
	bg_color = bg_color[0..6]
end

puts bg_color