# frozen_string_literal: true

require_relative "vec3"

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
          absorbed?: false
        )
      end
    end

    Metal = Data.define(:albedo, :fuzz) do
      def initialize(albedo:, fuzz:)
        super(albedo:, fuzz: (fuzz < 1.0) ? fuzz : 1.0)
      end

      def scatter(ray_in:, hit_record:)
        reflected = Materials.reflect(input_vec: ray_in.direction, normal: hit_record.normal)
        reflected = reflected.to_unit_vector + (fuzz * Vec3.random_unit_vector)

        Scattering.new(
          ray: Ray.new(origin: hit_record.point, direction: reflected),
          attenuation: albedo,
          absorbed?: reflected.dot(hit_record.normal) <= 0
        )
      end
    end

    Dielectric = Data.define(:refraction_index) do
      def scatter(ray_in:, hit_record:)
        ri = hit_record.is_front_face ? (1.0 / refraction_index) : refraction_index

        unit_direction = ray_in.direction.to_unit_vector
        cos_theta = [-unit_direction.dot(hit_record.normal), 1.0].min
        sin_theta = Math.sqrt(1.0 - cos_theta * cos_theta)

        cannot_refract = ri * sin_theta > 1.0
        direction = if cannot_refract || (Materials.reflectance(cosine: cos_theta, refraction_index: ri) > rand)
          Materials.reflect(
            input_vec: unit_direction,
            normal: hit_record.normal
          )
        else
          Materials.refract(
            uv: unit_direction,
            n: hit_record.normal,
            etai_over_etat: ri
          )
        end

        Scattering.new(
          ray: Ray.new(origin: hit_record.point, direction: direction),
          attenuation: Color.new(1.0, 1.0, 1.0),
          absorbed?: false
        )
      end
    end

    def self.reflect(input_vec:, normal:)
      input_vec - 2 * input_vec.dot(normal) * normal
    end

    def self.refract(uv:, n:, etai_over_etat:)
      cos_theta = [-uv.dot(n), 1.0].min
      r_out_perp = etai_over_etat * (uv + cos_theta * n)
      r_out_parallel = -Math.sqrt((1.0 - r_out_perp.length_squared).abs) * n
      r_out_perp + r_out_parallel
    end

    def self.reflectance(cosine:, refraction_index:)
      r0 = (1 - refraction_index) / (1 + refraction_index)
      r0 *= r0
      r0 + (1 - r0) * (1 - cosine)**5
    end
  end
end
