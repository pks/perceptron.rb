#!/usr/bin/env ruby

require 'zipf'

STDOUT.sync = true

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
ws = []
cs = []
ReadFile.readlines_strip(ARGV[1]).each { |l|
  c, s = l.split "\t"
  cs << c.to_i
  next if !s||s.strip==""
  ws << SparseVector.from_kv(s, "=", " ")
}

def sign(x)
  if x <= 0
    return -1.0
  else
    return 1.0
  end
end

test.each { |x|
  m = 0
  ws.each_with_index{ |w,j|
    m += sign(w.dot(x))*cs[j]
  }
  if m <= 0.0
    errors += 1
    puts -1
  else
    puts 1
  end
}

STDERR.write "accuracy = #{(test.size-errors)/test.size.to_f}\n"

