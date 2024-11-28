# frozen_string_literal: true
require "optparse"

module Rt
  module CommandLineParsing
    Options = Data.define(
      :show_output,
      :output_path,
      :image_width,
      :aspect_ratio,
      :samples_per_pixel
    ) do
      def initialize(
        show_output: false,
        output_path: "./test.ppm",
        image_width: 300,
        aspect_ratio: 16.0/9.0,
        samples_per_pixel: 5
      )
        super(show_output:, output_path:, image_width:, aspect_ratio:, samples_per_pixel:)
      end
    end

    def parse_options(args)
      options = {}

      parser = OptionParser.new

      parser.on("--show",) { |v| options[:show_output] = v }
      parser.on("-o", "--output_path PATH") { |v| options[:output_path] = v }
      parser.on("--image_width WIDTH") { |v| options[:image_width] = v }
      parser.on("--aspect_ratio RATIO") { |v| options[:aspect_ratio] = eval(v) }
      parser.on("--samples_per_pixel SAMPLES") { |v| options[:samples_per_pixel] = v }

      parser.parse!(args)

      Options.new(**options)
    end
  end
end
