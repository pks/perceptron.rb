#!/usr/bin/env ruby

require 'zipf'

class KbestItem
  attr_accessor :rank, :model, :gold, :f, :model_orig
  def initialize s
    a = s.split "\t"
    @rank = a[0].to_i
    @gold = a[1].to_f
    @model = a[2].to_f
    @model_orig = @model
    @f = SparseVector.from_kv a[3], "=", " "
  end

  def to_s
    return "#{@model}\t#{@gold}"
  end
end

`mkdir rrkb`
w = SparseVector.from_kv ReadFile.new(ARGV[0]).read, "\t", "\n"

STDERR.write "reranking..\n"
cur = []
k_sum = 0
j = 0
while line = STDIN.gets
  item = KbestItem.new line.strip
  item.model = w.dot(item.f)
  if item.rank == 0 && cur.size > 0
    cur.sort! { |i,j| j.model <=> i.model }
    f = WriteFile.new "rrkb/#{j}.gz"
    f.write cur.map{|x| x.to_s}.join("\n")
    f.close
    puts "RERANKED\t#{cur.first.gold}"
    cur = []
    j += 1
  end
  cur << item
end
cur.sort! { |i,j| j.model <=> i.model }
puts "RERANKED\t#{cur.first.gold}"

