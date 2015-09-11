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
  end

  describe "iteration" do
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
end
