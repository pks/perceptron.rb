#!/usr/bin/env ruby

require 'zipf'

class KbestItem
  attr_accessor :rank, :model, :rr, :gold, :f
  def initialize s
    a = s.split "\t"
    @rank = a[0].to_i
    @gold = a[1].to_f
    @model = a[2].to_f
    @rr    = -1.0
    @f = SparseVector.from_kv a[3], "=", " "
  end

  def to_s
    return "#{@model}\t#{@gold}"
  end
end

ws = []
cs = []
ReadFile.readlines_strip(ARGV[0]).each { |l|
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

def o kl
  scores = []
  scores << kl.first.gold
  kl.sort! { |i,j| j.model <=> i.model }
  scores << kl.first.gold
  kl.sort! { |i,j| j.rr <=> i.rr }
  scores << kl.first.gold

  puts scores.join "\t"
end

STDERR.write "reranking..\n"
cur = []
k_sum = 0
j = 0
while line = STDIN.gets
  item = KbestItem.new line.strip
  item.rr = 0
  ws.each_with_index{ |w,j|
    item.rr += sign(w.dot(x))*cs[j]
  }
  if item.rank == 0 && cur.size > 0
    o cur
    cur = []
    j += 1
  end
  cur << item
end
o cur

