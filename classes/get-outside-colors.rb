require 'oily_png'

class GetOutsideColors

	attr :preview_width
	attr :preview_height

	def initialize
		# Ensure these numbers are always floats, or else we'll end up with integer division, and the scale will just be 0
		@preview_width = 150.0
		@preview_height = 150.0
	end

	# get_color -> Returns the most common colours
	# img: An image (either from Oily/ChunkyPng or a File object or a string)
	def get_color( img, count=5 )

		# TODO - Add some testing around this.
		if img.class.name == 'String'
			img = ChunkyPNG::Image.from_file( img )
		elsif img.class.name == 'File'
			img = ChunkyPNG::Image.from_blob( img )
		end

		# Resize the image, because we only need the most significant colours.
		width = img.width
		height = img.height
		scale = 1
		if img.width > 0
			# Get the smaller of the scales
			scale =  [ (@preview_width / width), ( preview_height / height ) ].min
		end

		if scale < 1
			# Resize the image
			width = (scale * width).to_i
			height = (scale * height).to_i
			img = img.resize( width, height )
		end

		# The width and height are one pixel too wide for looping.
		width -= 1
		height -= 1

		# Loop through all the pixels on the outside edge
		pixel_count = 0
		color_array = Hash.new
		(0..height).each do |y|

			# First & last rows: All the pixels
			# All other rows: Just the first and last
			if y == 0 || y == height-1
				(0..width).each do |x|
					pixel_count = add_pixel_to_array( pixel_count, img, color_array, x, y )
				end
			else
				[0, width-1].each do |x|
					pixel_count = add_pixel_to_array( pixel_count, img, color_array, x, y )
				end
			end
		end

		# From absolute numbers to percentages
		# Commented out because this was really slowing the code down...
		color_array.each do |k, v|
			color_array[k] = ( v.to_f / pixel_count )
		end

		# Sort
		current_count = 0
		return_array = Hash.new
		color_array.sort_by {|k, v| -v}.each do |k, v|
			current_count += 1
			return_array[k] = v
			break if current_count >= count
		end

		return return_array
	end

	def add_pixel_to_array( pixel_count, img, color_array, x, y )
		pixel_count += 1
		color = img[x,y]

		if color_array.has_key? color
			color_array[ color ] += 1
		else
			color_array[ color ] = 1
		end
		return pixel_count
	end
end