#!/usr/bin/env ruby

require 'zipf'

STDERR.write "reading test data...\n"
test = []
test_f = ReadFile.new ARGV[0]
n = 0
while i = test_f.gets
  test << SparseVector.from_kv(i.strip, '=', ' ')
  n += 1
  STDERR.write "#{n}\n" if n%1000==0
end
STDERR.write " test set size = #{test.size}\n"

errors = 0
w = SparseVector.from_kv ReadFile.new(ARGV[1]).read, "\t", "\n"

test.each { |x|
  m = w.dot(x)
  if m <= 0.0
    errors += 1
    puts -1
  else
    puts 1
  end
}

STDERR.write "accuracy = #{(test.size-errors)/test.size.to_f}\n"

