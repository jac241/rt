module Rt
  class Vec3
    attr_accessor :x, :y, :z

    def initialize(x = 0, y = 0, z = 0)
      @x = x.to_f
      @y = y.to_f
      @z = z.to_f
    end

    # Class method to create new instance using []
    #def self.[](*args)
      #raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 3)" unless args.length == 3
      #new(*args)
    #end

    # Coercion method for operations with other types
    def coerce(other)
      case other
      when Numeric
        [self, other]
      else
        raise TypeError, "#{self.class} can't be coerced into #{other.class}"
      end
    end

    # Vector addition
    def +(other)
      self.class.new(@x + other.x, @y + other.y, @z + other.z)
    end

    def add!(other)
      @x += other.x
      @y += other.y
      @z += other.z
    end

    # Vector subtraction
    def -(other)
      self.class.new(@x - other.x, @y - other.y, @z - other.z)
    end

    def -@
      self.class.new(-@x, -@y, -@z)
    end

    # Multiplication - handles both scalar and vector multiplication
    def *(other)
      case other
      when Numeric
        self.class.new(@x * other, @y * other, @z * other)
      when self.class
        self.class.new(@x * other.x, @y * other.y, @z * other.z)
      else
        raise TypeError, "can't multiply Vector3 with #{other.class}"
      end
    end

    # Scalar division
    def /(scalar)
      raise ZeroDivisionError, "division by zero" if scalar == 0
      self.class.new(@x / scalar, @y / scalar, @z / scalar)
    end

    # Dot product
    def dot(other)
      @x * other.x + @y * other.y + @z * other.z
    end

    # Cross product
    def cross(other)
      self.class.new(
        @y * other.z - @z * other.y,
        @z * other.x - @x * other.z,
        @x * other.y - @y * other.x
      )
    end

    # Square of the magnitude
    def length_squared
      @x * @x + @y * @y + @z * @z
    end

    # Magnitude (length) of the vector
    def length
      Math.sqrt(length_squared)
    end
    alias magnitude length

    # Normalize the vector (create unit vector)
    def normalize
      len = length
      return self.class.new(0, 0, 0) if len == 0
      self.class.new(@x / len, @y / len, @z / len)
    end

    # Distance between two vectors
    def distance(other)
      (self - other).length
    end

    # Angle between two vectors (in radians)
    def angle(other)
      Math.acos(dot(other) / (length * other.length))
    end

    # String representation
    def to_s
      "(#{@x}, #{@y}, #{@z})"
    end

    # Equality comparison
    def ==(other)
      @x == other.x && @y == other.y && @z == other.z
    end

    alias to_unit_vector normalize

    # Zero vector
    def self.zero
      new(0, 0, 0)
    end

    def self.random(min: 0.0, max: 1.0)
      new(rand(min..max), rand(min..max), rand(min..max))
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
