#!/usr/bin/env ruby

require 'zipf'

STDERR.write "testing...\n"
test = []
test_f = ReadFile.new ARGV[0]
n = 0
errors = 0
w = SparseVector.from_kv ReadFile.new(ARGV[1]).read, "\t", "\n"
while i = test_f.gets
  x = SparseVector.from_kv(i.strip, '=', ' ')
  m = w.dot(x)
  if m <= 0.0
    errors += 1
    puts -1
  else
    puts 1
  end
  n += 1
  STDERR.write "#{n}\n" if n%1000==0
end
STDERR.write " test set size = #{n}\n"

STDERR.write "accuracy = #{(n-errors)/n.to_f}\n"

