require 'oily_png'
require File.join(File.dirname(__FILE__), 'get-outside-colors')

class ImageResizer

	attr :file_name
	attr :rotate
	attr :dest_width
	attr :dest_height
	
	attr :image 
	attr :width 
	attr :height
	attr :out_file

	def initialize( file_name, rotate=false, dest_width=nil, dest_height=nil, out_file=nil )
		@file_name   = file_name
		@rotate      = rotate
		@dest_width  = dest_width
		@dest_height = dest_height

		# Open the image and store the current width/height
		@image  = ChunkyPNG::Image.from_file( @file_name )
		@width  = @image.width
		@height = @image.height

		if @dest_width == nil and @dest_height == nil
			# What are you doing? NOT resizing, clearly.
			raise ArgumentError, 'Please provide either a width or a height.'
		end

		if @dest_width == nil
			@dest_width = @dest_height * @width / @height
		elsif @dest_height == nil
			@dest_height = @dest_width * @height / @width
		end

		@out_file    = out_file || "#{@file_name}_#{@dest_width}x#{@dest_height}.png"
	end

	def resize!
		# Get background colour
		bg_color = get_bg_color
		
		# Rotate
		@image = @image.rotate_right if @rotate

		scale = 1
		# Get the smaller of the scales
		scale =  [ (@dest_width.to_f / @width), ( @dest_height.to_f / @height ) ].min

		if scale < 1
			# Resize the image
			width = (scale * @width).to_i
			height = (scale * @height).to_i
			@image = @image.resize( width, height )
		else
			width = @width
			height = @height
		end

		# Resize
		vertical_offset = (@dest_height - height) / 2
		horizontal_offset = (@dest_width - width) / 2
		vertical_offset = 0 if vertical_offset < 0
		horizontal_offset = 0 if horizontal_offset < 0

		new_img = ChunkyPNG::Image.new( @dest_width, @dest_height, bg_color )
		new_img.compose!( @image, horizontal_offset, vertical_offset )
		new_img.save( @out_file, :fast_rgba )
	end

	def get_bg_color
		# Get the colours of the four corners
		top_left     = @image[0, 0]
		top_right    = @image[@width-1, 0]
		bottom_left  = @image[0, @height-1]
		bottom_right = @image[@width-1, @height-1]

		bg_color = 0
		if top_left == top_right and top_left == bottom_left and top_left == bottom_right
			# If the four corners are the same, use that as the background colour.
			bg_color = top_left
		else
			# If any of the corners is different, get the most common colour in the outside edge of the image.
			common_colors = GetOutsideColors.new
			colors = common_colors.get_color( @image, 1 )
			bg_color = colors.keys[0]
		end
		return bg_color
	end

end
