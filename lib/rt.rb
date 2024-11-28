# frozen_string_literal: true

require 'benchmark/ips'
require 'matrix'
require 'pathname'

require_relative "rt/vec3"
require_relative "rt/hittable_list"
require_relative "rt/sphere"
require_relative "rt/camera"
require_relative "rt/range_extensions"

module Rt
  def self.main
    world = HittableList.new([
      Sphere.new(center: Point3.new(0, 0, -1), radius: 0.5),
      Sphere.new(center: Point3.new(2, 0.75, -1.25), radius: 1.5),
      Sphere.new(center: Point3.new(0, -100.5, -1), radius: 100),
    ])

    camera = Camera.new(
      image_width: 200,
      aspect_ratio: 16.0 / 10.0,
      samples_per_pixel: 5
    )
    #path = Pathname.new("./test.ppm")

    #File.open(path, "w") do |f|
    #end
    colors = camera.render(world, out_file: nil)

    #`open #{path}`
    #File.open("test.ppm", "w") do |f|
      #f.puts "P3"
      #f.puts "#{image_width} #{image_height}"
      #f.puts "255"
      #f.puts colors.join("\n")
    #end
  end
end
