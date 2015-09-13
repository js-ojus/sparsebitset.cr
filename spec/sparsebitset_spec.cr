require "./spec_helper"

include SparseBitSet

describe SparseBitSet do
  describe "Basic operations" do
    it "should have a length of 0 upon creation" do
      s = BitSet.new()
      s.length.should eq(0)
    end

    it "should be empty upon creation" do
      s = BitSet.new()
      s.empty?.should eq(true)
    end

    it "should have no bits set upon creation" do
      s = BitSet.new()
      s.none?.should eq(true)
    end

    it "should set the given bit and test it" do
      s = BitSet.new()
      s.set(1_u64)
      s.test(1_u64).should eq(true)
    end

    it "should set the given bit, clear it and then test it" do
      s = BitSet.new()
      s.set(1_u64)
      s.clear(1_u64)
      s.test(1_u64).should eq(false)
    end

    it "should set the given bit, flip it and then test it" do
      s = BitSet.new()
      s.set(1_u64)
      s.flip(1_u64)
      s.test(1_u64).should eq(false)
    end

    it "should set the given bit and test it" do
      s = BitSet.new()
      s.set(100_u64)
      s.test(100_u64).should eq(true)
    end

    it "should set the given bit, clear it and then test it" do
      s = BitSet.new()
      s.set(100_u64)
      s.clear(100_u64)
      s.test(100_u64).should eq(false)
    end

    it "should set the given bit, flip it and then test it" do
      s = BitSet.new()
      s.set(100_u64)
      s.flip(100_u64)
      s.test(100_u64).should eq(false)
    end

    it "should set the given bit and test it" do
      s = BitSet.new()
      s.set(100_u64)
      s.set(1000_u64)
      s.test(1000_u64).should eq(true)
    end

    it "should set the given bit, clear it and then test it" do
      s = BitSet.new()
      s.set(100_u64)
      s.set(1000_u64)
      s.clear(100_u64)
      s.test(1000_u64).should eq(true)
    end

    it "should set the given bit, flip it and then test it" do
      s = BitSet.new()
      s.set(100_u64)
      s.set(1000_u64)
      s.flip(100_u64)
      s.test(1000_u64).should eq(true)
    end

    it "should set the given bit, flip it and then test it" do
      s = BitSet.new()
      s.set(100_u64)
      s.set(1000_u64)
      s.flip(1000_u64)
      s.test(100_u64).should eq(true)
    end

    it "should set the given bit, flip it and then test it" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      s.flip(1000_u64)
      s.length.should eq(2)
    end

    it "should set the given bit, flip it and then test it" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      s.flip(100_u64)
      s.length.should eq(2)
    end

    it "should clear the entire bitset and test it" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      s.clear_all()
      s.length.should eq(0)
    end
  end

  describe "cloning" do
    it "should clone a bitset, and test for equality of length" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = s.clone
      t.length.should eq(s.length)
    end

    it "should clone a bitset, and test for equality of individual bits" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = s.clone
      t.test(1_u64).should eq(true)
      t.test(100_u64).should eq(true)
      t.test(1000_u64).should eq(true)
    end

    it "should clone a bitset, and test for equality" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = s.clone
      (t == s).should eq(true)
    end
  end

  describe "iteration" do
    it "should answer nothing" do
      s = BitSet.new()
      iter = s.each
      ary = [] of UInt64
      while (i = iter.next) != Iterator::Stop::INSTANCE
        ary << (i as UInt64)
      end
      ary.should eq([] of UInt64)
    end

    it "should answer all set bits" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      iter = s.each
      ary = [] of UInt64
      while (i = iter.next) != Iterator::Stop::INSTANCE
        ary << (i as UInt64)
      end
      ary.should eq([1_u64, 100_u64, 1000_u64])
    end
  end

  describe "difference" do
    it "should answer null set" do
      s = BitSet.new()
      t = BitSet.new()
      w = s.difference(t)
      if w
        w.length.should eq(0)
      end
    end

    it "should result in a copy of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      w = s.difference(t)
      if w
        w.length.should eq(3)
      end
    end

    it "should result in length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      s.difference_cardinality(t).should eq(3)
    end

    it "should answer a smaller set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      w = s.difference(t)
      if w
        w.length.should eq(2)
      end
    end

    it "should result in smaller length" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.difference_cardinality(t).should eq(2)
    end

    it "should answer a smaller set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      w = s.difference(t)
      if w
        ary = [] of UInt64
        i = w.each
        while (el = i.next) != Iterator::Stop::INSTANCE
          ary << el as UInt64
        end
        ary.should eq([1_u64, 1000_u64])
      end
    end

    it "should answer null set" do
      s = BitSet.new()
      t = BitSet.new()
      s.difference!(t)
      s.length.should eq(0)
    end

    it "should result in a copy of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      s.difference!(t)
      s.length.should eq(3)
    end

    it "should answer a smaller set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.difference!(t)
      s.length.should eq(2)
    end

    it "should answer a smaller set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.difference!(t)

      ary = [] of UInt64
      i = s.each
      while (el = i.next) != Iterator::Stop::INSTANCE
        ary << el as UInt64
      end
      ary.should eq([1_u64, 1000_u64])
    end
  end

  describe "intersection" do
    it "should answer null set" do
      s = BitSet.new()
      t = BitSet.new()
      w = s.intersection(t)
      if w
        w.length.should eq(0)
      end
    end

    it "should result in zero length" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      w = s.intersection(t)
      if w
        w.length.should eq(0)
      end
    end

    it "should result in zero length" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      s.intersection_cardinality(t).should eq(0)
    end

    it "should answer a smaller set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      w = s.intersection(t)
      if w
        w.length.should eq(1)
      end
    end

    it "should result in smaller length" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.intersection_cardinality(t).should eq(1)
    end

    it "should answer a smaller set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      w = s.intersection(t)
      if w
        ary = [] of UInt64
        i = w.each
        while (el = i.next) != Iterator::Stop::INSTANCE
          ary << el as UInt64
        end
        ary.should eq([100_u64])
      end
    end

    it "should answer null set" do
      s = BitSet.new()
      t = BitSet.new()
      s.intersection!(t)
      s.length.should eq(0)
    end

    it "should result in null set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      s.intersection!(t)
      s.length.should eq(0)
    end

    it "should answer a smaller set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.intersection!(t)
      s.length.should eq(1)
    end

    it "should answer a smaller set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.intersection!(t)

      ary = [] of UInt64
      i = s.each
      while (el = i.next) != Iterator::Stop::INSTANCE
        ary << el as UInt64
      end
      ary.should eq([100_u64])
    end
  end

  describe "union" do
    it "should answer null set" do
      s = BitSet.new()
      t = BitSet.new()
      w = s.union(t)
      if w
        w.length.should eq(0)
      end
    end

    it "should result in a length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      w = s.union(t)
      if w
        w.length.should eq(3)
      end
    end

    it "should result in a length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      s.union_cardinality(t).should eq(3)
    end

    it "should result in a length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      w = s.union(t)
      if w
        w.length.should eq(3)
      end
    end

    it "should result in a length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.union_cardinality(t).should eq(3)
    end

    it "should result in a full union" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(10_u64)
      w = s.union(t)
      if w
        ary = [] of UInt64
        i = w.each
        while (el = i.next) != Iterator::Stop::INSTANCE
          ary << el as UInt64
        end
        ary.should eq([1_u64, 10_u64, 100_u64, 1000_u64])
      end
    end

    it "should answer null set" do
      s = BitSet.new()
      t = BitSet.new()
      s.union!(t)
      s.length.should eq(0)
    end

    it "should result in the length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      s.union!(t)
      s.length.should eq(3)
    end

    it "should result in the length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.union!(t)
      s.length.should eq(3)
    end

    it "should answer a full union" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(10_u64)
      s.union!(t)

      ary = [] of UInt64
      i = s.each
      while (el = i.next) != Iterator::Stop::INSTANCE
        ary << el as UInt64
      end
      ary.should eq([1_u64, 10_u64, 100_u64, 1000_u64])
    end
  end

  describe "symmetric_difference" do
    it "should answer null set" do
      s = BitSet.new()
      t = BitSet.new()
      w = s.symmetric_difference(t)
      if w
        w.length.should eq(0)
      end
    end

    it "should result in a length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      w = s.symmetric_difference(t)
      if w
        w.length.should eq(3)
      end
    end

    it "should result in a length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      s.symmetric_difference_cardinality(t).should eq(3)
    end

    it "should result in a length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      w = s.symmetric_difference(t)
      if w
        w.length.should eq(2)
      end
    end

    it "should result in a length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.symmetric_difference_cardinality(t).should eq(2)
    end

    it "should result in a full symmetric_difference" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(10_u64)
      w = s.symmetric_difference(t)
      if w
        ary = [] of UInt64
        i = w.each
        while (el = i.next) != Iterator::Stop::INSTANCE
          ary << el as UInt64
        end
        ary.should eq([1_u64, 10_u64, 100_u64, 1000_u64])
      end
    end

    it "should answer null set" do
      s = BitSet.new()
      t = BitSet.new()
      s.symmetric_difference!(t)
      s.length.should eq(0)
    end

    it "should result in the length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      s.symmetric_difference!(t)
      s.length.should eq(3)
    end

    it "should result in the length of the original set" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(100_u64)
      s.symmetric_difference!(t)
      s.length.should eq(2)
    end

    it "should answer a full symmetric_difference" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = BitSet.new()
      t.set(10_u64)
      s.symmetric_difference!(t)

      ary = [] of UInt64
      i = s.each
      while (el = i.next) != Iterator::Stop::INSTANCE
        ary << el as UInt64
      end
      ary.should eq([1_u64, 10_u64, 100_u64, 1000_u64])
    end
  end
end
