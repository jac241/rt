# frozen_string_literal: true
require "parallel"
require "concurrent-ruby"

require_relative "ray"
require_relative "color"

module Rt
  class Camera
    attr_reader :image_width, :image_height, :aspect_ratio, :center,
      :pixel_delta_u, :pixel_delta_v, :pixel00_loc, :samples_per_pixel,
      :pixel_samples_scale, :max_depth, :vfov, :lookfrom, :lookat, :vup,
      :defocus_angle, :focus_dist

    attr_reader :u, :v, :w # camera frame basis vectors
    attr_reader :defocus_disk_u, :defocus_disk_v
    def initialize(
      image_width:,
      aspect_ratio:,
      samples_per_pixel: 10,
      max_depth: 10,
      vfov: 90,
      lookfrom: Point3.new(0.0, 0.0, 0.0),
      lookat: Point3.new(0.0, 0.0, -1.0),
      vup: Vec3.new(0.0, 1.0, 0.0),
      defocus_angle: 0,
      focus_dist: 10
    )
      @image_width = image_width
      @aspect_ratio = aspect_ratio
      @center = lookfrom
      @lookfrom = lookfrom
      @lookat = lookat
      @vup = vup

      @image_height = (@image_width / @aspect_ratio).to_i
      @image_height = (@image_height < 1) ? 1 : @image_height

      @samples_per_pixel = samples_per_pixel
      @pixel_samples_scale = 1.0 / samples_per_pixel

      @max_depth = max_depth
      @defocus_angle = defocus_angle
      @focus_dist = focus_dist

      theta = Rt.degrees_to_radians(vfov)
      h = Math.tan(theta / 2)
      viewport_height = 2 * h * @focus_dist

      viewport_width = viewport_height * (image_width.to_f / image_height)

      @w = (@lookfrom - @lookat).to_unit_vector
      @u = @vup.cross(@w).to_unit_vector
      @v = w.cross(@u)
      
      viewport_u = viewport_width * u
      viewport_v = viewport_height * -v

      @pixel_delta_u = viewport_u / image_width
      @pixel_delta_v = viewport_v / image_height

      viewport_upper_left = @center - (@focus_dist * w) - viewport_u/2 - viewport_v/2
      @pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

      defocus_radius = focus_dist * Math.tan(Rt.degrees_to_radians(@defocus_angle / 2))
      @defocus_disk_u = @u * defocus_radius
      @defocus_disk_v = @v * defocus_radius
    end

    def render(world, out_file:)
      # pool = Concurrent::FixedThreadPool.new(5)
      #colors = Parallel.map((0...image_height).to_a, in_threads: 10) do |j|
      (0...image_height).flat_map do |j|
        (0...image_width).map do |i|
          pixel_color = Color.new(0.0, 0.0, 0.0)

          samples_per_pixel.times do
            pixel_color += Rt.color_for_ray(
              make_sample_ray(i, j),
              max_depth,
              world
            )
          end

          (pixel_samples_scale * pixel_color).to_ppm
        end
      end
    end

    private

    def make_sample_ray(pixel_loc_i, pixel_loc_j)
      offset = Rt.sample_square
      pixel_sample = pixel00_loc + (
          ((pixel_loc_i + offset.x) * pixel_delta_u) +
          ((pixel_loc_j + offset.y) * pixel_delta_v)
      )
      Ray.new(
        origin: defocus_angle <= 0 ? center : defocus_disk_sample,
        direction: pixel_sample - center
      )
    end

    def defocus_disk_sample
      p = Rt.random_vec3_in_unit_disk
      center + (p.x * defocus_disk_u) + (p.y * defocus_disk_v)
    end
  end

  def self.degrees_to_radians(degrees) = degrees * Math::PI / 180

  def self.color_for_ray(ray, depth, world)
    return Color.new(0.0, 0.0, 0.0) if depth <= 0

    if (hit_record = world.maybe_hit(ray:, ray_tmin: 0.001, ray_tmax: Float::INFINITY))
      scattering = hit_record.material.scatter(ray_in: ray, hit_record: hit_record)

      if scattering.absorbed?
        return Color.new(0.0, 0.0, 0.0)
      else
        return scattering.attenuation * color_for_ray(scattering.ray, depth - 1, world)
      end
    end

    unit_direction = ray.direction.to_unit_vector
    a = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a)*Color.new(1.0, 1.0, 1.0) + a*Color.new(0.5, 0.7, 1.0)
  end

  def self.sample_square
    Vec3.new(rand - 0.5, rand - 0.5, 0.0)
  end

  def self.random_vec3_on_hemisphere(normal)
    on_unit_sphere = Vec3.random_unit_vector

    if on_unit_sphere.dot(normal) > 0.0
      on_unit_sphere
    else
      -on_unit_sphere
    end
  end

  def self.random_vec3_in_unit_disk
    while true
      p = Vec3.new(rand(-1.0..1.0), rand(-1.0..1.0), 0.0)
      return p if p.length_squared < 1
    end
  end

end

