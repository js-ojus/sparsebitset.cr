require "./bench_helper"

include SparseBitSet

def bm_001()
  s = BitSet.new()
  n = 100000
  r = Random.new()
  tbeg = Time.now
  (1..n).each do |_|
    s.set(r.rand(n).to_u64)
  end
  tend = Time.now
  printf("\nRandom set     : %8d ns/op\n", (tend-tbeg).ticks * 100 / n)
end

def bm_002()
  s = BitSet.new()
  n = 100000
  r = Random.new()
  tbeg = Time.now
  (1..n).each do |_|
    s.test(r.rand(n).to_u64)
  end
  tend = Time.now
  printf("\nRandom test    : %8d ns/op\n", (tend-tbeg).ticks * 100 / n)
end

def bm_003()
  n = 100000
  tbeg = Time.now
  (1..n).each do |_|
    s = BitSet.new()
    s.set(n.to_u64)
  end
  tend = Time.now
  printf("\nCreation test  : %8d ns/op\n", (tend-tbeg).ticks * 100 / n)
end

def bm_004()
  n = 100000
  s = BitSet.new()
  (1..1000).each do |i|
    s.set(i.to_u64*100)
  end
  c = 0
  tbeg = Time.now
  (1..n).each do |_|
    c += s.length
  end
  tend = Time.now
  puts c
  printf("\nCount test     : %8d ns/op\n", (tend-tbeg).ticks * 100 / n)
end

def bm_005()
  n = 1000
  s = BitSet.new()
  (1..3333).each do |i|
    s.set(i.to_u64*3)
  end
  tbeg = Time.now
  (1..n).each do |_|
    iter = s.each
    c = 0
    while iter.next != Iterator::Stop::INSTANCE
      c += 1
    end
  end
  tend = Time.now
  printf("\nIteration test : %8d ns/op\n", (tend-tbeg).ticks * 100 / n)
end

def bm_006()
  n = 500
  s = BitSet.new()
  (1..3333).each do |i|
    s.set(i.to_u64*30)
  end
  tbeg = Time.now
  (1..n).each do |_|
    iter = s.each
    c = 0
    while iter.next != Iterator::Stop::INSTANCE
      c += 1
    end
  end
  tend = Time.now
  printf("\nIteration test : %8d ns/op\n", (tend-tbeg).ticks * 100 / n)
end

def main()
  bm_001()
  bm_002()
  bm_003()
  bm_004()
  bm_005()
  bm_006()
end

main()
