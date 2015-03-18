#!/usr/bin/env ruby

require 'zipf'

def dot v, w
  sum = 0.0
  v.each_with_index { |k,i|
   sum += k * w[i]
  }

  return sum
end

def elen v
  len = 0.0
  v.each { |i| len += i**2 }
  return Math.sqrt len
end

def norm v
  len = elen v
  return v.map { |i| i/len }
end

STDERR.write "loading feature dict\n"
fd = Marshal.load ReadFile.read ARGV[0]
d = fd.size
STDERR.write "#{d}\n"

STDERR.write "loading model\n"
w = Marshal.load ReadFile.read ARGV[1]

STDERR.write "predicting..\n"
err = 0
loss = 0.0
i = 0
while line = STDIN.gets
  x = [0.0] * d
  line.split.each { |i|
    k,v = i.split '=', 2
    x[fd[k]] = v.to_f
  }
  m = dot(w, norm(x))
  if m <= 0.0
    puts -1
    loss += m.abs
    err += 1
  else
    puts 1
  end
  i += 1
end

STDERR.write "#{err}/#{test.size}% accuracy, loss=#{loss}\n"

