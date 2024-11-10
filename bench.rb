# frozen_string_literal: true
require 'benchmark/ips'

require_relative "lib/rt"

def suppress_output
  original_stdout, original_stderr = $stdout.clone, $stderr.clone
  $stderr.reopen File.new('/dev/null', 'w')
  $stdout.reopen File.new('/dev/null', 'w')
  yield
ensure
  $stdout.reopen original_stdout
  $stderr.reopen original_stderr
end

Benchmark.ips do |x|
  x.config(warumup: 4, time: 5)
  x.report("render") do
    suppress_output do
      Rt.main
    end
  end
end
