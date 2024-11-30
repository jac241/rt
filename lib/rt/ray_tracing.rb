# frozen_string_literal: true

module Rt
  module RayTracing
    def self.color_for_ray(starting_ray, max_depth, world)
      stack = []
      attenuations = []
      stack.push([starting_ray, max_depth])

      while stack.any?
        ray, depth = stack.pop

        if depth <= 0
          attenuations.append Color.new(0.0, 0.0, 0.0)
          break
        end

        if (hit_record = world.maybe_hit(ray:, ray_tmin: 0.001, ray_tmax: Float::INFINITY))
          scattering = hit_record.material.scatter(ray_in: ray, hit_record: hit_record)

          if scattering.absorbed?
            attenuations.append Color.new(0.0, 0.0, 0.0)
            break
          else
            attenuations.append scattering.attenuation
            stack.push([scattering.ray, depth - 1])
          end
        else
          unit_direction = starting_ray.direction.to_unit_vector
          a = 0.5 * (unit_direction.y + 1.0)
          attenuations.append (1.0 - a) * Color.new(1.0, 1.0, 1.0) + a * Color.new(0.5, 0.7, 1.0)
          break
        end
      end

      attenuations.reduce(&:*)
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
      loop do
        p = Vec3.new(rand(-1.0..1.0), rand(-1.0..1.0), 0.0)
        return p if p.length_squared < 1
      end
    end
  end
end
