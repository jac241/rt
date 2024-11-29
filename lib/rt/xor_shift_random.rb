# frozen_string_literal: true

require "concurrent/thread_safe/util/xor_shift_random"

module Rt
  class XORShiftRandom
    attr_accessor :state
    # template <typename T> inline T xorShift_UNI() { return         xorShift()  * UNI_32BIT_INV; } // _UNI<T>   returns value in [ 0, 1] with T ==> float/double
    # template <typename T> inline T xorShift_VNI() { return int32_t(xorShift()) * VNI_32BIT_INV; } // _VNI<T>   returns value in [-1, 1] with T ==> float/double
    # template <typename T> inline T xorShift_Range(T min, T max)                                   // _Range<T> returns value in [min, max] with T ==> float/double
    #        { return min + (max-min) * xorShift_UNI<T>(); }
    UNI_64BIT_INV = 5.42101086242752217003726400434970e-20
    VNI_64BIT_INV = 1.08420217248550443400745280086994e-19

    Rand = Concurrent::ThreadSafe::Util::XorShiftRandom

    def initialize
      @state = Rand.get
    end

    def rand
      self.state = Rand.xorshift(self.state)
      self.state * UNI_64BIT_INV
    end

    def rand_range(range)
      range.min + (range.max - range.min) * rand
    end
  end
end
