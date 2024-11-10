# frozen_string_literal: true

require 'benchmark/ips'
require 'matrix'

require_relative "rt/vec3"
require_relative "rt/hittable_list"
require_relative "rt/sphere"
require_relative "rt/camera"
require_relative "rt/range_extensions"

module Rt
  def self.main
    world = HittableList.new([
      Sphere.new(center: Point3[0, 0, -1], radius: 0.5),
      Sphere.new(center: Point3[0, -100.5, -1], radius: 100),
    ])

    camera = Camera.new(image_width: 200, aspect_ratio: 16.0 / 9.0)
    camera.render(world)
  end
end

# monkey patch range
Range.include Rt::RangeExtensions

