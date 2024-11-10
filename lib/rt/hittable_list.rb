# frozen_string_literal: true

module Rt
  class HittableList
    attr_reader :objects

    def initialize(objects = nil)
      @objects = objects || Array.new
    end

    def <<(object)
      objects << object
    end

    def clear
      objects.clear
    end

    def maybe_hit(ray:, ray_tmin:, ray_tmax:)
      result_rec = nil
      closest_so_far = ray_tmax

      objects.each do |object|
        if (found_rec = object.maybe_hit(ray:, ray_tmin:, ray_tmax: closest_so_far))
          closest_so_far = found_rec.t
          result_rec = found_rec
        end
      end

      result_rec
    end
  end
end
