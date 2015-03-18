#!/usr/bin/env ruby

require 'zipf'

class KbestItem
  attr_accessor :rank, :model, :gold, :f, :id
  def initialize s
    a = s.split "\t"
    @rank = a[0].to_i
    @gold = a[1].to_f
    @model = a[2].to_f
    @f = SparseVector.from_kv a[3], "=", " "
    @id = -1
  end
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

STDERR.write "loading feature dict\n"
fd = Marshal.load ReadFile.read ARGV[0]
d = fd.size
STDERR.write "#{d}\n"

STDERR.write "loading model\n"
w = Marshal.load ReadFile.read ARGV[1]

STDERR.write "reranking..\n"
kbest_lists = []
cur = []
while line = STDIN.gets
  item = KbestItem.new line.strip
  x = [0.0] * d
  line.split("\t")[3].split.each { |i|
    k,v = i.split '=', 2
    x[fd[k]] = v.to_f
  }
  m = dot(w, norm(x))
  item.model = m
  if item.rank == 0 && cur.size > 0
    kbest_lists << cur
    cur = []
  end
  cur << item
end
kbest_lists << cur

kbest_lists.each { |l|
  puts "RERANKED\t#{l.sort { |i,j| j.model <=> i.model }.first.gold}"
}


