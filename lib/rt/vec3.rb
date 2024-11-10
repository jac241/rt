module Rt
  class Vec3 < Vector
    def initialize(array)
      raise "Trying to construct Vec3 with array with size #{array.size}" unless array.size == 3

      super(array.map(&:to_f))
    end

    def x = @elements[0]
    def y = @elements[1]
    def z = @elements[2]

    def length_squared
      @elements[0] * @elements[0] + @elements[1] * @elements[1] + @elements[2] * @elements[2]
    end

    def length
      Math.sqrt(length_squared)
    end

    def to_unit_vector
      self / self.length
    end

    def self.random(min: 0.0, max: 1.0)
      self[rand(min..max), rand(min..max), rand(min..max)]
    end

    def self.random_unit_vector
      while true
        p = self.random
        lensq = p.length_squared

        if 1e-160 < lensq && lensq <= 1.0
          return p / Math.sqrt(lensq)
        end
      end
    end
  end

  Point3 = Vec3
end
