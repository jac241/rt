# frozen_string_literal: true

module Rt
  module Worlds
    def default_world
      material_ground = Materials::Lambertian.new(Color.new(0.8, 0.8, 0))
      material_center = Materials::Lambertian.new(Color.new(0.1, 0.2, 0.5))
      material_left = Materials::Dielectric.new(1.5)
      material_bubble = Materials::Dielectric.new(1.0 / 1.5)
      material_right = Materials::Metal.new(albedo: Color.new(0.8, 0.6, 0.2), fuzz: 1.0)

      HittableList.new([
        Sphere.new(center: Point3.new(0.0, -100.5, -1.0), radius: 100, material: material_ground),
        Sphere.new(center: Point3.new(0.0, 0.0, -1.2), radius: 0.5, material: material_center),
        Sphere.new(center: Point3.new(-1.0, 0.0, -1.0), radius: 0.5, material: material_left),
        Sphere.new(center: Point3.new(-1.0, 0.0, -1.0), radius: 0.4, material: material_bubble),
        Sphere.new(center: Point3.new(1.0, 0.0, -1.0), radius: 0.5, material: material_right)
      ])
    end
  end
end
