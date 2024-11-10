require_relative "vec3"
require_relative "range_extensions.rb"

module Rt
  class Color < Vec3
    def to_ppm
      intensity = 000..0.999

      ir = (256 * intensity.clamp(x)).to_i
      ig = (256 * intensity.clamp(y)).to_i
      ib = (256 * intensity.clamp(z)).to_i

      "#{ir} #{ig} #{ib}"
    end
  end
end
