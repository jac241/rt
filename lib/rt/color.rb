require_relative "vec3"
require_relative "range_extensions"

module Rt
  class Color < Vec3
    def to_ppm
      intensity = 0o00..0.999

      r = Rt.linear_to_gamma(x)
      g = Rt.linear_to_gamma(y)
      b = Rt.linear_to_gamma(z)

      ir = (256 * intensity.clamp(r)).to_i
      ig = (256 * intensity.clamp(g)).to_i
      ib = (256 * intensity.clamp(b)).to_i

      "#{ir} #{ig} #{ib}"
    end
  end

  def self.linear_to_gamma(linear_component)
    if linear_component > 0
      Math.sqrt(linear_component)
    else
      0
    end
  end
end
