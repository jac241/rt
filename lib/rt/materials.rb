# frozen_string_literal: true
require_relative 'vec3'

module Rt
  module Materials
    Scattering = Data.define(:ray, :attenuation)

    Lambertian = Data.define(:albedo) do
      def scatter(ray_in:, hit_record:)
        scatter_direction = hit_record.normal + Vec3.random_unit_vector

        scatter_direction = hit_record.normal if scatter_direction.near_zero?

        Scattering.new(
          ray: Ray.new(origin: hit_record.point, direction: scatter_direction),
          attenuation: albedo
        )
      end
    end

    Metal = Data.define(:albedo) do
      def scatter(ray_in:, hit_record:)
        reflection = Materials.reflect(input_vec: ray_in.direction, normal: hit_record.normal)

        Scattering.new(
          ray: Ray.new(origin: hit_record.point, direction: reflection),
          attenuation: albedo
        )
      end
    end

    def self.reflect(input_vec:, normal:)
      input_vec - 2*input_vec.dot(normal)*normal
    end
  end
end
