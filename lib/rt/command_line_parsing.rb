# frozen_string_literal: true
require "optparse"

require_relative "vec3"

module Rt
  module CommandLineParsing
    Options = Data.define(
      :show_output,
      :output_path,
      :image_width,
      :aspect_ratio,
      :samples_per_pixel,
      :max_depth,
      :camera_vfov,
      :camera_lookfrom,
      :camera_lookat,
      :camera_defocus_angle,
      :camera_focus_dist,
    ) do
      def initialize(
        show_output: false,
        output_path: "./test.ppm",
        image_width: 300,
        aspect_ratio: 16.0/9.0,
        samples_per_pixel: 5,
        max_depth: 50,
        camera_vfov: 40,
        camera_lookfrom: Point3.new(-2, 2, 1),
        camera_lookat: Point3.new(0, 0, -1),
        camera_defocus_angle: 1.0,
        camera_focus_dist: 1
      )
        super(
          show_output:,
          output_path:,
          image_width:,
          aspect_ratio:,
          samples_per_pixel:,
          max_depth:,
          camera_vfov:,
          camera_lookfrom:,
          camera_lookat:,
          camera_defocus_angle:,
          camera_focus_dist:
        )
      end
    end

    def parse_options(args)
      options = {}

      parser = OptionParser.new

      parser.on("--show",) { |v| options[:show_output] = v }
      parser.on("-o", "--output_path PATH") { |v| options[:output_path] = v }
      parser.on("--image_width WIDTH") { |v| options[:image_width] = v.to_i }
      parser.on("--aspect_ratio RATIO") { |v| options[:aspect_ratio] = eval(v) }
      parser.on("--samples_per_pixel SAMPLES") { |v| options[:samples_per_pixel] = v.to_i }

      parser.on("--max_depth INTEGER") { |v| options[:max_depth] = v.to_i }
      parser.on("--camera_vfov FLOAT") { |v| options[:camera_vfov] = v.to_f }
      parser.on("--camera_lookfrom POINT3") { |v| options[:camera_lookfrom] = string_to_point3(v) }
      parser.on("--camera_lookat POINT3") { |v| options[:camera_lookfrom] = string_to_point3(v) }
      parser.on("--camera_defocus_angle FLOAT") { |v| options[:camera_defocus_angle] = v.to_f }
      parser.on("--camera_focus_dist FLOAT") { |v| options[:camera_focus_dist] = v.to_f }
      parser.parse!(args)

      Options.new(**options)
    end

    def string_to_point3(s)
      Point3.new(*s.split(",").map(&:to_f))
    end
  end
end
