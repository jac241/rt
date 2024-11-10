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
  end

  Point3 = Vec3

  class Color < Vec3
    def to_ppm
      ir = (255.999 * x).to_i
      ig = (255.999 * y).to_i
      ib = (255.999 * z).to_i

      "#{ir} #{ig} #{ib}"
    end
  end
end
