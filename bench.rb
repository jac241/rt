# frozen_string_literal: true
require 'benchmark/ips'

require_relative "lib/rt"

Benchmark.ips do |x|
  x.config(warumup: 10, time: 5)
  x.report("render") do
    Rt.main
  end
end
