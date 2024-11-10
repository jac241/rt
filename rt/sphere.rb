# frozen_string_literal: true

module Rt
  Sphere = Data.define(:center, :radius) do

    def maybe_hit(ray:, ray_tmin:, ray_tmax:)
      oc = center - ray.origin

      a = ray.direction.dot(ray.direction) 
      #b = -2.0 * ray.direction.dot(oc)
      h = ray.direction.dot(oc)
      c = oc.length_squared - radius*radius
      discriminant = h*h - a*c

      return nil if discriminant < 0

      sqrtd = Math.sqrt(discriminant)

      root = (h - sqrtd) / a
      if root <= ray_tmin || ray_tmax <= root
        root = (h + sqrtd) / a
        return nil if root <= ray_tmin || ray_tmax <= root
      end

      result = HitRecord.new
      result.t = root
      result.point = ray.at(root)

      outward_normal = (result.point - center) / radius
      result.set_face_normal(ray:, outward_normal:)

      result
    end

  end
end
