module Rt
  module RangeExtensions
    def surrounds(item)
      first < item < last
    end

    def clamp(value)
      if value < min
        min
      elsif value > max
        max
      else
        value
      end
    end
  end
end

Range.include Rt::RangeExtensions
