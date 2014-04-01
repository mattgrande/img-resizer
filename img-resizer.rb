#!/usr/bin/env ruby

require 'optparse'
require File.join(File.dirname(__FILE__), 'classes', 'image-resizer')

options = {
	:width  => nil,
	:height => nil,
	:output_filename => nil
}
optparse = OptionParser.new do |opts|
	opts.banner = 'Usage: img-resizer.rb [options]'

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

	opts.on('-o [output filename]', '--output_filename [output filename]', 'The file name to write. Defaults to [old_filename]_[width]x[height].png') do |ofn|
		options[:output_filename] = ofn
	end

	opts.on('-w [width]', '--width [width]', 'The desired width of the image, in pixels.') do |w_in|
		w = Integer(w_in) rescue nil
		if w.nil?
			puts "Width '#{w_in}' is not a valid integer"
			exit
		end
		options[:width] = w
	end

	opts.on('-h [height]', '--height [height]', 'The desired height of the image, in pixels.') do |h_in|
		h = Integer(h_in) rescue nil
		if h.nil?
			puts "Height '#{h_in}' is not a valid integer"
			exit
		end
		options[:height] = h
	end

	opts.on('-?', '--help', 'Display this screen') do
		puts opts
		exit
	end
end

optparse.parse!

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

resizer = ImageResizer.new( options[:file_name], false, options[:width], options[:height], options[:output_filename] )
resizer.resize!
