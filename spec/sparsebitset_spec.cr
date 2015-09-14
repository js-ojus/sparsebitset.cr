require "./spec_helper"

include SparseBitSet

describe SparseBitSet do
  describe "basic operations" do
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

    it "should answer `false` for a non-empty set" do
      s = BitSet.new()
      s.set(1_u64)
      s.none?.should eq(false)
    end

    it "should have no bits set upon creation" do
      s = BitSet.new()
      s.any?.should eq(false)
    end

    it "should answer `true` for a non-empty set" do
      s = BitSet.new()
      s.set(1_u64)
      s.any?.should eq(true)
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

    it "should answer all set bits" do
      s = BitSet.new()
      s.set(100_u64)
      s.set(1000_u64)
      iter = s.each
      ary = [] of UInt64
      while (i = iter.next) != Iterator::Stop::INSTANCE
        ary << (i as UInt64)
      end
      ary.should eq([100_u64, 1000_u64])
    end

    it "should answer all set bits" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(1000_u64)
      iter = s.each
      ary = [] of UInt64
      while (i = iter.next) != Iterator::Stop::INSTANCE
        ary << (i as UInt64)
      end
      ary.should eq([1_u64, 1000_u64])
    end

    it "should answer a subset of bits" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      iter = s.each
      ary = [] of UInt64
      i = iter.next(1_u64)
      ary << i as UInt64
      while (i = iter.next) != Iterator::Stop::INSTANCE
        ary << (i as UInt64)
      end
      ary.should eq([1_u64, 100_u64, 1000_u64])
    end

    it "should answer a subset of bits" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(100_u64)
      s.set(1000_u64)
      iter = s.each
      ary = [] of UInt64
      i = iter.next(2_u64)
      ary << i as UInt64
      while (i = iter.next) != Iterator::Stop::INSTANCE
        ary << (i as UInt64)
      end
      ary.should eq([100_u64, 1000_u64])
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

  describe "symmetric difference" do
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

  describe "complement" do
    it "should be empty" do
      s = BitSet.new()
      t = s.complement()
      t.empty?.should eq(true)
    end

    it "should be empty" do
      s = BitSet.new()
      s.set(1_u64)
      t = s.complement()
      t.empty?.should eq(true)
    end

    it "should have a length that is prior length - 1" do
      s = BitSet.new()
      s.set(10_u64)
      t = s.complement()
      t.length.should eq(9)
    end

    it "should have a length that is prior length - 1" do
      s = BitSet.new()
      s.set(100_u64)
      t = s.complement()
      t.length.should eq(99)
    end

    it "should have a length that is prior length - 2" do
      s = BitSet.new()
      s.set(10_u64)
      s.set(100_u64)
      t = s.complement()
      t.length.should eq(98)
    end

    it "should have a length that is prior length - 3" do
      s = BitSet.new()
      s.set(10_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = s.complement()
      t.length.should eq(997)
    end

    it "should have a length that is prior length - 3" do
      s = BitSet.new()
      s.set(64_u64)
      s.set(100_u64)
      s.set(1000_u64)
      t = s.complement()
      t.length.should eq(997)
    end
  end

  describe "set-wide predicates" do
    it "should answer `false`" do
      s = BitSet.new()
      s.all?.should eq(false)
    end

    it "should answer `true`" do
      s = BitSet.new()
      s.set(1_u64)
      s.all?.should eq(true)
    end

    it "should answer `false`" do
      s = BitSet.new()
      s.set(10_u64)
      s.all?.should eq(false)
    end

    it "should answer `false`" do
      s = BitSet.new()
      s.set(100_u64)
      s.all?.should eq(false)
    end

    it "should answer `true`" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(2_u64)
      s.all?.should eq(true)
    end

    it "should answer `true`" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(2_u64)
      s.set(3_u64)
      s.set(4_u64)
      s.set(5_u64)
      s.set(6_u64)
      s.set(7_u64)
      s.set(8_u64)
      s.set(9_u64)
      s.set(11_u64)
      s.set(12_u64)
      s.set(13_u64)
      s.set(14_u64)
      s.set(15_u64)
      s.set(16_u64)
      s.set(17_u64)
      s.set(18_u64)
      s.set(19_u64)
      s.set(21_u64)
      s.set(22_u64)
      s.set(23_u64)
      s.set(24_u64)
      s.set(25_u64)
      s.set(26_u64)
      s.set(27_u64)
      s.set(28_u64)
      s.set(29_u64)
      s.set(31_u64)
      s.set(32_u64)
      s.set(33_u64)
      s.set(34_u64)
      s.set(35_u64)
      s.set(36_u64)
      s.set(37_u64)
      s.set(38_u64)
      s.set(39_u64)
      s.set(41_u64)
      s.set(42_u64)
      s.set(43_u64)
      s.set(44_u64)
      s.set(45_u64)
      s.set(46_u64)
      s.set(47_u64)
      s.set(48_u64)
      s.set(49_u64)
      s.set(51_u64)
      s.set(52_u64)
      s.set(53_u64)
      s.set(54_u64)
      s.set(55_u64)
      s.set(56_u64)
      s.set(57_u64)
      s.set(58_u64)
      s.set(59_u64)
      s.set(61_u64)
      s.set(62_u64)
      s.set(63_u64)
      s.set(64_u64)
      s.set(65_u64)
      s.set(66_u64)
      s.set(67_u64)
      s.set(68_u64)
      s.set(69_u64)
      s.all?.should eq(true)
    end

    it "should answer `true`" do
      s = BitSet.new()
      s.set(64_u64)
      s.set(65_u64)
      s.set(66_u64)
      s.set(67_u64)
      s.set(68_u64)
      s.set(69_u64)
      s.all?.should eq(false)
    end
  end

  describe "superset" do
    it "should check two empty sets" do
      s = BitSet.new()
      t = BitSet.new()
      s.superset?(t).should eq(true)
    end

    it "should check a non-empty and an empty set" do
      s = BitSet.new()
      s.set(64_u64)
      t = BitSet.new()
      s.superset?(t).should eq(true)
    end

    it "should check a non-empty and an empty set" do
      s = BitSet.new()
      s.set(64_u64)
      t = BitSet.new()
      t.superset?(s).should eq(false)
    end

    it "should check two equal sets" do
      s = BitSet.new()
      s.set(64_u64)
      t = BitSet.new()
      t.set(64_u64)
      s.superset?(t).should eq(true)
    end

    it "should check two unequal sets" do
      s = BitSet.new()
      s.set(1_u64)
      s.set(64_u64)
      t = BitSet.new()
      t.set(64_u64)
      s.superset?(t).should eq(true)
    end

    it "should check two unequal sets" do
      s = BitSet.new()
      s.set(64_u64)
      t = BitSet.new()
      t.set(1_u64)
      t.set(64_u64)
      s.superset?(t).should eq(false)
    end

    it "should check two empty sets" do
      s = BitSet.new()
      t = BitSet.new()
      s.strict_superset?(t).should eq(false)
    end

    it "should check a non-empty and an empty set" do
      s = BitSet.new()
      s.set(64_u64)
      t = BitSet.new()
      t.strict_superset?(s).should eq(false)
    end

    it "should check two equal sets" do
      s = BitSet.new()
      s.set(64_u64)
      t = BitSet.new()
      t.set(64_u64)
      s.strict_superset?(t).should eq(false)
    end

    it "should check two unequal sets" do
      s = BitSet.new()
      s.set(64_u64)
      t = BitSet.new()
      t.set(1_u64)
      t.set(64_u64)
      s.strict_superset?(t).should eq(false)
    end

    it "should check two unequal sets" do
      s = BitSet.new()
      s.set(64_u64)
      t = BitSet.new()
      t.set(1_u64)
      t.set(64_u64)
      t.strict_superset?(s).should eq(true)
    end
  end
end
