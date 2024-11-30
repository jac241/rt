# frozen_string_literal: true

require "bundler/setup"

require "pathname"

require_relative "rt/command_line_parsing"
require_relative "rt/vec3"
require_relative "rt/hittable_list"
require_relative "rt/sphere"
require_relative "rt/camera"
require_relative "rt/color"
require_relative "rt/range_extensions"
require_relative "rt/materials"
require_relative "rt/worlds"

module Rt
  extend CommandLineParsing
  extend Worlds
  def self.main(args = ARGV, options: nil, world: nil)
    options ||= parse_options(args)
    world ||= default_world

    camera = make_camera(options)

    colors = camera.render(world, parallel: options.parallel)

    path = Pathname.new(options.output_path)

    save_ppm_image(
      colors:,
      image_height: camera.image_height,
      image_width: camera.image_width,
      path:
    )

    `open #{path}` if options.show_output
  end

  def self.make_camera(options)
    Camera.new(
      image_width: options.image_width,
      aspect_ratio: options.aspect_ratio,
      samples_per_pixel: options.samples_per_pixel,
      vfov: options.camera_vfov,
      lookfrom: options.camera_lookfrom,
      lookat: options.camera_lookat,
      vup: Vec3.new(0, 1, 0),
      defocus_angle: options.camera_defocus_angle,
      focus_dist: options.camera_focus_dist
    )
  end

  def self.save_ppm_image(colors:, image_height:, image_width:, path:)
    File.open(path, "w") do |f|
      f.puts "P3"
      f.puts "#{image_width} #{image_height}"
      f.puts "255"
      f.puts colors.join("\n")
    end
  end
end
