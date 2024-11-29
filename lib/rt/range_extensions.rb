module Rt
  module RangeExtensions
    def surrounds(item)
      first < item && item < last
    end

    def clamp(value)
      value.clamp(min, max)
    end
  end
end

Range.include Rt::RangeExtensions
