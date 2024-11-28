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

module Rt
  extend CommandLineParsing
  def self.main(args = ARGV)
    options = parse_options(args)

    world = HittableList.new([
      Sphere.new(center: Point3.new(0, 0, -1), radius: 0.5),
      Sphere.new(center: Point3.new(2, 0.75, -1.25), radius: 1.5),
      Sphere.new(center: Point3.new(0, -100.5, -1), radius: 100),
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
