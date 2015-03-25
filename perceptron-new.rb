#!/usr/bin/env ruby

require 'zipf'

STDERR.write "reading training data...\n"
train = []
train_f = ReadFile.new ARGV[0]
n = 0
while i = train_f.gets
  train << SparseVector.from_kv(i.strip, '=', ' ')
  n += 1
  STDERR.write "#{n}\n" if n%1000==0
end
STDERR.write " training set size = #{train.size}\n"

prev_loss = Float::MAX # converged?
T = 1000000            # max number of iterations
t = 0
w = SparseVector.new   # 0 vector
no_change = 0
save_freq = 1
if ARGV[1]
  save_freq = ARGV[1].to_i
end

while true

  if t == T
    STDERR.write "\nreached max. number of iterations!\n"
    break
  end

  STDERR.write "\niteration #{t}\n"

  train.shuffle!
  loss = 0.0
  errors = 0
  j = 1

  train.each { |x|
    m = w.dot(x)
    if m <= 0.0
      loss += m.abs
      errors += 1
      w += x
    end
    STDERR.write '.'  if j%10==0
    STDERR.write "\n" if j%1000==0
    j += 1
  }

  STDERR.write "errors = #{errors} (avg = #{(errors/train.size.to_f).round 2}), loss = #{loss.round 2} (avg = #{(loss/train.size).round 2})\n"

  if (loss.abs-prev_loss.abs).abs <= 10**-4
    no_change += 1
  else
    no_change = 0
  end
  if no_change == 3
    STDERR.write "\nno change in loss since three iterations (difference < 10**-4)!\n"
    break
  end
  prev_loss = loss

  if t%save_freq == 0
    STDERR.write "\nwriting model to model.#{t}.gz ...\n"
    f = WriteFile.new "model.#{t}.gz"
    f.write w.to_kv("\t", "\n")+"\n"
    f.close
    STDERR.write "done!\n"
  end

  t += 1
end

STDERR.write "\nwriting model to model.final.gz ...\n"
f = WriteFile.new "model.final.gz"
f.write w.to_kv("\t", "\n")+"\n"
f.close
STDERR.write "done!\n"

