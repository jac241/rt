# frozen_string_literal: true

require_relative "ray"
require_relative "color"
require_relative "xor_shift_random"
require_relative "ray_tracing"

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

      viewport_upper_left = @center - (@focus_dist * w) - viewport_u / 2 - viewport_v / 2
      @pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

      defocus_radius = focus_dist * Math.tan(Rt.degrees_to_radians(@defocus_angle / 2))
      @defocus_disk_u = @u * defocus_radius
      @defocus_disk_v = @v * defocus_radius
    end

    def render(world, parallel: false)
      Thread.current[:random] = XORShiftRandom.new

      if parallel
        parallel_render(world)
      else
        serial_render(world)
      end
    end

    def serial_render(world)
      (0...image_height).flat_map do |j|
        (0...image_width).map do |i|
          pixel_color = Color.new(0.0, 0.0, 0.0)

          samples_per_pixel.times do
            pixel_color += RayTracing.color_for_ray(
              make_sample_ray(i, j),
              max_depth,
              world
            )
          end

          (pixel_samples_scale * pixel_color).to_ppm
        end
      end
    end

    def parallel_render(world) # can be slightly faster for high quality scenes
      indices = image_height.times.flat_map { |j| image_width.times.map { |i| [i, j] } }
      thread_count = 10

      threads = indices.each_slice(thread_count).map do |indices_for_thread|
        Thread.new do
          Thread.current[:random] = XORShiftRandom.new

          indices_for_thread.map do |(i, j)|
            pixel_color = Color.new(0.0, 0.0, 0.0)

            samples_per_pixel.times do
              pixel_color += RayTracing.color_for_ray(
                make_sample_ray(i, j),
                max_depth,
                world
              )
            end
            (pixel_samples_scale * pixel_color).to_ppm
          end
        end
      end
      threads.each(&:join)
      threads.map(&:value).reduce(&:+)
    end

    private

    def make_sample_ray(pixel_loc_i, pixel_loc_j)
      offset = RayTracing.sample_square
      pixel_sample = pixel00_loc + (
          ((pixel_loc_i + offset.x) * pixel_delta_u) +
          ((pixel_loc_j + offset.y) * pixel_delta_v)
        )
      Ray.new(
        origin: (defocus_angle <= 0) ? center : defocus_disk_sample,
        direction: pixel_sample - center
      )
    end

    def defocus_disk_sample
      p = RayTracing.random_vec3_in_unit_disk
      center + (p.x * defocus_disk_u) + (p.y * defocus_disk_v)
    end
  end

  def self.degrees_to_radians(degrees) = degrees * Math::PI / 180
end
