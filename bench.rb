# frozen_string_literal: true

require "benchmark/ips"

require_relative "lib/rt"

world = Rt::HittableList.new(
  [
    Rt::Sphere.new(
      center: Rt::Point3.new(0.0, -100.5, -1.0),
      radius: 100,
      material: Rt::Materials::Lambertian.new(Rt::Color.new(0.8, 0.8, 0.8))
    ),
    Rt::Sphere.new(
      center: Rt::Point3.new(0.0, 0.0, -1.2),
      radius: 0.5,
      material: Rt::Materials::Lambertian.new(Rt::Color.new(0.1, 0.2, 0.5))
    ),
    Rt::Sphere.new(
      center: Rt::Point3.new(-1.0, 0, -1.0),
      radius: 0.5,
      material: Rt::Materials::Dielectric.new(1.5)
    ),
    Rt::Sphere.new(
      center: Rt::Point3.new(-1.0, 0.0, -1.0),
      radius: 0.4,
      material: Rt::Materials::Dielectric.new(1.0 / 1.5)
    ),
    Rt::Sphere.new(
      center: Rt::Point3.new(1.0, 0.0, -1.0),
      radius: 0.5,
      material: Rt::Materials::Metal.new(
        albedo: Rt::Color.new(0.8, 0.6, 0.2), fuzz: 0.2
      )
    )
  ]
)

options = Rt::CommandLineParsing::Options.new(
  show_output: false,
  output_path: "./bench.ppm",
  image_width: 100,
  aspect_ratio: 16.0 / 9.0,
  samples_per_pixel: 10,
  max_depth: 50,
  camera_vfov: 20,
  camera_lookfrom: Rt::Point3.new(-2, 2, 1),
  camera_lookat: Rt::Point3.new(0, 0, -1),
  camera_defocus_angle: 0.01,
  camera_focus_dist: 10.0,
  parallel: false
)

Rt::CommandLineParsing::Options.new(
  show_output: false,
  output_path: "./bench.ppm",
  image_width: 300,
  aspect_ratio: 16.0 / 9.0,
  samples_per_pixel: 20,
  max_depth: 50,
  camera_vfov: 20,
  camera_lookfrom: Rt::Point3.new(-2, 2, 1),
  camera_lookat: Rt::Point3.new(0, 0, -1),
  camera_defocus_angle: 0.01,
  camera_focus_dist: 10.0,
  parallel: true
)

Benchmark.ips do |x|
  x.config(warumup: 5, time: 15, iterations: 3)

  x.report("render-serial") do
    Rt.main(options:, world:)
  end
  # x.report("render-parallel") do
  #   Rt.main(options: options_parallel, world:)
  # end

  # x.compare!
end
