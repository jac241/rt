module Rt
  class Ray
    attr_reader :origin, :direction

    def initialize(origin:, direction:)
      @origin = origin
      @direction = direction
    end

    def at(t)
      origin + t*direction
    end
  end

  def self.degrees_to_radians(degrees)
    degrees.to_f * Math::PI / 180.0
  end
end
