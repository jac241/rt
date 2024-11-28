# frozen_string_literal: true

require 'benchmark/ips'
require 'matrix'
require 'pathname'

require_relative 'rt/command_line_parsing'
require_relative "rt/vec3"
require_relative "rt/hittable_list"
require_relative "rt/sphere"
require_relative "rt/camera"
require_relative "rt/range_extensions"
require_relative 'rt/materials'

module Rt
  extend CommandLineParsing
  def self.main(args = ARGV)
    options = parse_options(args)

    material_ground = Materials::Lambertian.new(Color.new(0.8, 0.8, 0.0))
    material_center = Materials::Lambertian.new(Color.new(0.1, 0.2, 0.5))
    material_left = Materials::Metal.new(Color.new(0.8, 0.8, 0.8))
    material_right = Materials::Metal.new(Color.new(0.8, 0.6, 0.2))

    world = HittableList.new([
      Sphere.new(center: Point3.new(0, -100.5, -1), radius: 100, material: material_ground),
      Sphere.new(center: Point3.new(0, 0, -1.2), radius: 0.5, material: material_center),
      Sphere.new(center: Point3.new(-1.0, 0.0, -1.0), radius: 0.5, material: material_left),
      Sphere.new(center: Point3.new(1.0, 0.0, -1.0), radius: 0.5, material: material_right),
    ])

    camera = Camera.new(
      image_width: options.image_width,
      aspect_ratio: options.aspect_ratio,
      samples_per_pixel: options.samples_per_pixel,
    )

    colors = camera.render(world, out_file: nil)

    path = Pathname.new(options.output_path)
    $stderr.puts "Writing image to path: #{path}"

    File.open(path, "w") do |f|
      f.puts "P3"
      f.puts "#{camera.image_width} #{camera.image_height}"
      f.puts "255"
      f.puts colors.join("\n")
    end

    `open #{path}` if options.show_output
  end
end
