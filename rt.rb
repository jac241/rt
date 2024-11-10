# frozen_string_literal: true

require 'benchmark/ips'
require 'matrix'

require_relative "rt/vec3"
require_relative "rt/hit_record"
require_relative "rt/hittable_list"
require_relative "rt/sphere"
require_relative "rt/camera"

# monkey patch range
class Range
  def surrounds(item)
    first < item < last
  end
end

module Rt
  def self.color_for_ray(ray, world)
    if (hit_record = world.maybe_hit(ray:, ray_tmin: 0, ray_tmax: Float::INFINITY))
      return Color.elements(0.5 * (hit_record.normal + Color[1.0, 1.0, 1.0]))
    end

    unit_direction = ray.direction.to_unit_vector
    a = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a)*Color[1.0, 1.0, 1.0] + a*Color[0.5, 0.7, 1.0]
  end

  def self.main
    world = HittableList.new([
      Sphere.new(center: Point3[0, 0, -1], radius: 0.5),
      Sphere.new(center: Point3[0, -100.5, -1], radius: 100),
    ])

    camera = Camera.new(image_width: 400, aspect_ratio: 16.0 / 9.0)
    camera.render(world)
  end
end
