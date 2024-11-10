# frozen_string_literal: true

require 'benchmark/ips'
require 'matrix'

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
  class Vec3 < Vector
    def initialize(array)
      raise "Trying to construct Vec3 with array with size #{array.size}" unless array.size == 3

      super(array.map(&:to_f))
    end

    def x = @elements[0]
    def y = @elements[1]
    def z = @elements[2]

    def length_squared
      @elements[0] * @elements[0] + @elements[1] * @elements[1] + @elements[2] * @elements[2]
    end

    def length
      Math.sqrt(length_squared)
    end

    def to_unit_vector
      self / self.length
    end
  end

  Point3 = Vec3

  class Color < Vec3
    def to_ppm
      ir = (255.999 * x).to_i
      ig = (255.999 * y).to_i
      ib = (255.999 * z).to_i

      "#{ir} #{ig} #{ib}"
    end
  end

  class Ray
    attr_reader :origin, :direction

    def initialize(origin:, direction:)
      @origin = origin
      @direction = direction
    end

    def at(t)
      origin + t*direction
    end
  end

  def self.degrees_to_radians(degrees)
    degrees.to_f * Math::PI / 180.0
  end

  def self.ray_color(ray, world)
    #return Color[1, 0, 0] if hit_sphere(center: Point3[0, 0, -1], radius: 0.5, ray: ray)
    #t = hit_sphere(center: Point3[0, 0, -1], radius: 0.5, ray: ray)
    if (hit_record = world.maybe_hit(ray:, ray_tmin: 0, ray_tmax: Float::INFINITY))
      return Color.elements(0.5 * (hit_record.normal + Color[1.0, 1.0, 1.0]))
    end

    #if t > 0.0
      #normal = (ray.at(t) - Vec3[0, 0, -1]).to_unit_vector
      #return 0.5 * Color[normal.x + 1, normal.y + 1, normal.z + 1]
    #end

    unit_direction = ray.direction.to_unit_vector
    a = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a)*Color[1.0, 1.0, 1.0] + a*Color[0.5, 0.7, 1.0]
  end

  def self.hit_sphere(center:, radius:, ray:)
    oc = center - ray.origin

    a = ray.direction.dot(ray.direction) 
    #b = -2.0 * ray.direction.dot(oc)
    h = ray.direction.dot(oc)
    c = oc.length_squared - radius*radius
    discriminant = h*h - a*c

    discriminant < 0 ? -1.0 : (h - Math.sqrt(discriminant)) / a
  end

  def self.main
    #aspect_ratio = 16.0 / 9.0
    #image_width = 400

    #image_height = (image_width / aspect_ratio).to_i
    #image_height = (image_height < 1) ? 1 : image_height

    world = HittableList.new([
      Sphere.new(center: Point3[0, 0, -1], radius: 0.5),
      Sphere.new(center: Point3[0, -100.5, -1], radius: 100),
    ])

    camera = Camera.new(image_width: 400, aspect_ratio: 16.0 / 9.0)
    camera.render(world)

    #focal_length = 1.0
    #viewport_height = 2.0
    #viewport_width = viewport_height * (image_width.to_f / image_height)
    #camera_center = Point3[0, 0, 0]
    
    #viewport_u = Vec3[viewport_width, 0, 0]
    #viewport_v = Vec3[0, -viewport_height, 0]

    #pixel_delta_u = viewport_u / image_width
    #pixel_delta_v = viewport_v / image_height

    #viewport_upper_left = camera_center - Vec3[0, 0, focal_length] - (viewport_u / 2) - (viewport_v / 2)
    #pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)
   
    #puts "P3"
    #puts "#{image_width} #{image_height}"
    #puts "255"

    #colors = (0...image_height).flat_map do |j|
      #(0...image_width).map do |i|
        #pixel_center = pixel00_loc + (i * pixel_delta_u) + (j * pixel_delta_v)
        #ray_direction = pixel_center - camera_center

        #ray = Ray.new(origin: camera_center, direction: ray_direction)
        #pixel_color = ray_color(ray, world)

        ##pixel_color =
          ##Color[
            ##i.to_f / (image_width - 1), 
            ##j.to_f / (image_height - 1),
            ##0.0
          ##]
        #pixel_color.to_ppm
      #end
    #end
    #puts colors.join("\n")

  end


  #Benchmark.ips do |x|
    #x.config(warumup: 4, time: 5)

    ##a1 = random_array
    ##a2 = random_array

    ##result = Array.new(a1.size) { Array.new(a2.size) }


    #x.report("multiplication") do
      #main
      ##a3 = a1 * a2
      ##a3 = a3 + a1 + a2
      ##multiply(a1, a2, result)
    #end
  #end
end

Rt.main
