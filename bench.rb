# frozen_string_literal: true
require 'benchmark/ips'

require_relative "lib/rt"

options = %w[--image_width 200 --aspect_ratio 1.0 --samples_per_pixel 5]

Benchmark.ips do |x|
  x.config(warumup: 10, time: 5)
  x.report("render") do
    Rt.main(options)
  end
end
