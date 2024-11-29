# frozen_string_literal: true

module Rt
  HitRecord = Struct.new(:point, :normal, :material, :t, :is_front_face, keyword_init: true) do
    def set_face_normal(ray:, outward_normal:)
      self.is_front_face = ray.direction.dot(outward_normal) < 0
      self.normal = is_front_face ? outward_normal : -outward_normal
    end
  end
end
