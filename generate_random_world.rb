# frozen_string_literal: true

require_relative 'lib/rt'

options = %w[--show --image_width 200 --aspect_ratio 1.0 --samples_per_pixel 5]

material_ground = Rt::Materials::Lambertian.new(Rt::Color.new(0.8, 0.8, 0.8))
material_center = Rt::Materials::Lambertian.new(Rt::Color.new(0.1, 0.2, 0.5))
material_left = Rt::Materials::Dielectric.new(1.5)
material_bubble = Rt::Materials::Dielectric.new(1.0 / 1.5)
material_right = Rt::Materials::Metal.new(albedo: Rt::Color.new(0.8, 0.6, 0.2), fuzz: 1.0)

world = Rt::HittableList.new(
  [
    Rt::Sphere.new(center: Rt::Point3.new(0.0, -100.5, -1.0), radius: 100, material: material_ground),
    Rt::Sphere.new(center: Rt::Point3.new(0.0,    0.0, -1.2), radius: 0.5, material: material_center),
    Rt::Sphere.new(center: Rt::Point3.new(-1.0,   0.0, -1.0), radius: 0.5, material: material_left),
    Rt::Sphere.new(center: Rt::Point3.new(-1.0,   0.0, -1.0), radius: 0.4, material: material_bubble),
    Rt::Sphere.new(center: Rt::Point3.new(1.0,    0.0, -1.0), radius: 0.5, material: material_right),
  ]
)

Rt.main(options, world:)
