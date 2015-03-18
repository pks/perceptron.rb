#!/usr/bin/env ruby

require 'zipf'

puts "loading feature dict"
fd = Marshal.load ReadFile.read ARGV[0]
d = fd.size
puts d

puts "reading training data"
train = []
l_i = 1
while line = STDIN.gets
  puts l_i if l_i%1000==0
  v = [0.0] * d 
  line.split.each { |i|
    k,w = i.split '=', 2
    v[fd[k]] = w.to_f
  }
  train << v
  l_i+= 1
end

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

def add v, w, l
  v.each_with_index { |k,i| v[i] = k + (w[i]*l) }
  return v
end

T = 12
l = 0.001
train.map! { |v| norm(v) }
w = []
d.times { w << rand(0.001..0.005) }
w = norm(w)

margin = ARGV[1].to_f

T.times { |t|
  STDERR.write "iteration #{t}\n"

  loss = 0.0
  train.each { |x|
    m = dot(w, x)
    if m < margin
      loss += m.abs
      w = norm(add(w,x,l))
    end
  }
  STDERR.write "loss = #{loss}\n"
}

f = File.new('model', 'w') 
f.write Marshal.dump w

