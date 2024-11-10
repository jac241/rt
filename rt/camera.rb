# frozen_string_literal: true
require_relative "ray"

module Rt
  class Camera
    attr_reader :image_width, :image_height, :aspect_ratio, :center,
      :pixel_delta_u, :pixel_delta_v, :pixel00_loc

    def initialize(image_width:, aspect_ratio:, center: Point3[0.0, 0.0, 0.0])
      @image_width = image_width
      @aspect_ratio = aspect_ratio
      @center = center

      @image_height = (@image_width / @aspect_ratio).to_i
      @image_height = (@image_height < 1) ? 1 : @image_height

      focal_length = 1.0
      viewport_height = 2.0
      viewport_width = viewport_height * (image_width.to_f / image_height)
      
      viewport_u = Vec3[viewport_width, 0, 0]
      viewport_v = Vec3[0, -viewport_height, 0]

      @pixel_delta_u = viewport_u / image_width
      @pixel_delta_v = viewport_v / image_height

      viewport_upper_left = @center - Vec3[0, 0, focal_length] - (viewport_u / 2) - (viewport_v / 2)
      @pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)
    end

    def render(world)
      puts "P3"
      puts "#{image_width} #{image_height}"
      puts "255"

      colors = (0...image_height).flat_map do |j|
        (0...image_width).map do |i|
          pixel_center = pixel00_loc + (i * pixel_delta_u) + (j * pixel_delta_v)
          ray_direction = pixel_center - self.center

          ray = Ray.new(origin: self.center, direction: ray_direction)
          pixel_color = Rt.color_for_ray(ray, world)

          #pixel_color =
          #Color[
          #i.to_f / (image_width - 1), 
          #j.to_f / (image_height - 1),
          #0.0
          #]
          pixel_color.to_ppm
        end
      end
      puts colors.join("\n")
    end
  end
end

