# frozen_string_literal: true
require_relative 'vec3'

module Rt
  module Materials
    Scattering = Data.define(:ray, :attenuation, :absorbed?)

    Lambertian = Data.define(:albedo) do
      def scatter(ray_in:, hit_record:)
        scatter_direction = hit_record.normal + Vec3.random_unit_vector

        scatter_direction = hit_record.normal if scatter_direction.near_zero?

        Scattering.new(
          ray: Ray.new(origin: hit_record.point, direction: scatter_direction),
          attenuation: albedo,
          absorbed?: false,
        )
      end
    end

    Metal = Data.define(:albedo, :fuzz) do
      def initialize(albedo:, fuzz:)
        super(albedo:, fuzz: fuzz < 1.0 ? fuzz : 1.0)
      end
      def scatter(ray_in:, hit_record:)
        reflected = Materials.reflect(input_vec: ray_in.direction, normal: hit_record.normal)
        reflected = reflected.to_unit_vector + (fuzz * Vec3.random_unit_vector)

        Scattering.new(
          ray: Ray.new(origin: hit_record.point, direction: reflected),
          attenuation: albedo,
          absorbed?: reflected.dot(hit_record.normal) <= 0,
        )
      end
    end

    def self.reflect(input_vec:, normal:)
      input_vec - 2*input_vec.dot(normal)*normal
    end
  end
end
