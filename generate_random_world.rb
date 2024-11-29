# frozen_string_literal: true

require_relative 'lib/rt'

# options = %w[--show --image_width 200 --aspect_ratio 1.0 --samples_per_pixel 5]

random_spheres =
  (-11...11).flat_map do |a|
    (-11..11).map do |b|
      choose_mat = rand
      center = Rt::Point3.new(a + 0.9*rand, 0.2, b+0.9*rand)

      if (center - Rt::Point3.new(4.0, 0.2, 0.0)).length > 0.9
        if choose_mat < 0.8
          Rt::Sphere.new(
            center: center,
            radius: 0.2,
            material: Rt::Materials::Lambertian.new(
              albedo: Rt::Color.random * Rt::Color.random
            )
          )
        elsif choose_mat < 0.95
          Rt::Sphere.new(
            center: center,
            radius: 0.2,
            material: Rt::Materials::Metal.new(
              albedo: Rt::Color.random(min: 0.5, max: 1.0),
              fuzz: rand(0.0..0.5)
            )
          )
        else
          Rt::Sphere.new(
            center: center,
            radius: 0.2,
            material: Rt::Materials::Dielectric.new(
              refraction_index: 1.5
            )
          )
        end
      end
    end
  end

material_ground = Rt::Materials::Lambertian.new(Rt::Color.new(0.5, 0.5, 0.5))
ground = Rt::Sphere.new(center: Rt::Point3.new(0.0, -1000, -1.0), radius: 1000, material: material_ground)

world = Rt::HittableList.new(
  [
    ground,
    Rt::Sphere.new(
      center: Rt::Point3.new(0.0, 1.0, 0.0),
      radius: 1.0,
      material: Rt::Materials::Dielectric.new(1.5)
    ),
    Rt::Sphere.new(
      center: Rt::Point3.new(-4, 1.0, 0.0),
      radius: 1.0,
      material: Rt::Materials::Lambertian.new(Rt::Color.new(0.4, 0.2, 0.1))
    ),
    Rt::Sphere.new(
      center: Rt::Point3.new(4.0, 1.0, 0.0),
      radius: 1.0,
      material: Rt::Materials::Metal.new(albedo: Rt::Color.new(0.7, 0.6, 0.5), fuzz: 0.0)
    ),
    *random_spheres.compact,
  ]
)

options = Rt::CommandLineParsing::Options.new(
  show_output: true,
  output_path: "./world.ppm",
  image_width: 1920,
  aspect_ratio: 16.0/9.0,
  samples_per_pixel: 100,
  max_depth: 50,
  camera_vfov: 20,
  camera_lookfrom: Rt::Point3.new(13, 2, 3),
  camera_lookat: Rt::Point3.new(0, 0, 0),
  camera_defocus_angle: 0.05,
  camera_focus_dist: 10.0
)

Rt.main(options:, world:)
