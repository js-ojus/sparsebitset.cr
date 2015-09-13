# (c) Copyright 2015 JONNALAGADDA Srinivas
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# Package sparsebitset is a simple implementation of sparse bitsets for non-
# negative integers.  This is a port of `github.com/js-ojus/sparsebitset`,
# which is written in Go (golang).
#
# The representation is very simple, and uses a sequence of (offset, bits)
# pairs.  It is similar to that of Go's `x/tools/container/intsets` and Java's
# `java.util.BitSet`.
#
# The original motivation for `sparsebitset` comes from a need to store custom
# indexes of documents in a database.  Accordingly, `sparsebitset` trades CPU
# time for space.

require "./sparsebitset/*"

module SparseBitSet

  # Size of a word in bits.
  WORD_SIZE = sizeof(UInt64) * 8_u64
  # (`WORD_SIZE` - 1)
  MOD_WORD_SIZE = WORD_SIZE - 1_u64
  # Number of bits to right-shift by, to divide by WORD_SIZE.
  LOG2_WORD_SIZE = 6_u64
  # A word with all bits set to `1`.
  ALL_ONES = 0xffffffffffffffff_u64

  #

  DE_BRUIJN = [] of UInt8
  DE_BRUIJN.concat [0_u8, 1_u8, 56_u8, 2_u8, 57_u8, 49_u8, 28_u8, 3_u8, 61_u8,
    58_u8, 42_u8, 50_u8, 38_u8, 29_u8, 17_u8, 4_u8, 62_u8, 47_u8, 59_u8,
    36_u8, 45_u8, 43_u8, 51_u8, 22_u8, 53_u8, 39_u8, 33_u8, 30_u8, 24_u8,
    18_u8, 12_u8, 5_u8, 63_u8, 55_u8, 48_u8, 27_u8, 60_u8, 41_u8, 37_u8,
    16_u8, 46_u8, 35_u8, 44_u8, 21_u8, 52_u8, 32_u8, 23_u8, 11_u8, 54_u8,
    26_u8, 40_u8, 15_u8, 34_u8, 20_u8, 31_u8, 10_u8, 25_u8, 14_u8, 19_u8,
    9_u8, 13_u8, 8_u8, 7_u8, 6_u8,]

  # A quick way to find the number of trailing zeroes in the word.
  private def trailing_zeroes_count(v : UInt64) : UInt64
    (DE_BRUIJN[(((0_u64-v) & v) * 0x03f79d71b4ca8b09) >> 58]).to_u64
  end

  # popcount answers the number of bits set to `1` in this word.  It uses
  # the bit population count (Hamming Weight) logic taken from
  # https://code.google.com/p/go/issues/detail?id=4988#c11.  Original by
  # 'https://code.google.com/u/arnehormann'.
  private def popcount(x : UInt64) : UInt64
    x -= (x >> 1) & 0x5555555555555555
    x =  ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333)
    x += x >> 4
    x &= 0x0f0f0f0f0f0f0f0f
    x *= 0x0101010101010101
    x >> 56
  end

  # popcountSet answers the number of bits set to `1` in the given set.
  private def popcountSet(set : Array(Block)) : UInt64
    set.inject(0_u64) do |cnt, el|
     cnt + popcount(el.bits)
   end
  end

  # Block is a pair of (offset, bits) capable of holding information for up
  # to `WORD_SIZE` elements.
  struct Block
    @offset :: UInt64
    @bits :: UInt64

    getter offset
    property bits

    def initialize(@offset, @bits)
      # Intentionally left blank.
    end

    # set sets the bit at the given position.
    def set(n : UInt64) : Block
      @bits = @bits | (1_u64 << n)
      self
    end

    # clear resets the bit at the given position.
    def clear(n : UInt64) : Block
      @bits = @bits & ~(1_u64 << n)
      self
    end

    # flip inverts the bit at the given position.
    def flip(n : UInt64) : Block
      @bits = @bits ^ (1_u64 << n)
      self
    end

    # test checks to see if the bit at the given position is set.
    def test(n : UInt64)
      @bits & (1_u64 << n) > 0
    end
  end

  # SbsIterator provides iteration over a sparse bitset.
  class SbsIterator
    include Iterator(UInt64)

    @set :: Array(Block)
    @curr :: UInt64

    def initialize(@set)
      @curr = 0_u64
    end

    # next answers the position of the next bit that is set.  If no such
    # bit exists, it answers `Iterator::Stop::INSTANCE`.
    def next
      off, rsh = @curr >> LOG2_WORD_SIZE, @curr & MOD_WORD_SIZE

      idx = nil
      @set.each_with_index do |el, i|
        if el.offset == off
          w = el.bits >> rsh
          if w > 0
            @curr += trailing_zeroes_count(w) + 1
            return @curr-1
          end
        end
        if el.offset > off
          idx = i
          break
        end
      end

      if idx
        @curr = (@set[idx].offset * WORD_SIZE) + trailing_zeroes_count(@set[idx].bits) + 1
        @curr-1
      else
        Iterator::Stop::INSTANCE
      end
    end
  end

  # BitSet is a compact representation of sparse sets of non-negative
  # integers.
  class BitSet
    include Iterable

    @set :: Array(Block)

    def initialize
      @set = Array(Block).new()
    end

    protected def raw_set : Array(Block)
      @set
    end

    private def off_bit(n : UInt64) : Tuple(UInt64, UInt64)
      return n >> LOG2_WORD_SIZE, n & MOD_WORD_SIZE
    end

    # set sets the bit at the given position.
    def set(n : UInt64) : BitSet
      off, bit = off_bit(n)

      idx = nil
      @set.each_with_index do |el, i|
        if el.offset == off
          el.set(bit)
          @set[i] = el
          return self
        end
        if el.offset > off
          idx = i
          break
        end
      end

      blk = Block.new(off, 0_u64)
      blk.set(bit)
      if idx
        @set.insert(idx, blk)
      else
        @set.push(blk)
      end
      self
    end

    # clear resets the bit at the given position.
    def clear(n : UInt64) : BitSet
      off, bit = off_bit(n)

      idx = @set.index { |el| el.offset == off }
      return self unless idx

      @set[idx] = @set[idx].clear(bit)
      if @set[idx].bits == 0
        @set.delete(idx)
      end
      self
    end

    # flip inverts the bit at the given position.
    def flip(n : UInt64) : BitSet
      off, bit = off_bit(n)

      idx = @set.index { |el| el.offset == off }
      return self unless idx

      @set[idx] = @set[idx].flip(bit)
      self
    end

    # test answers `true` if the bit at the given position is set; `false`
    # otherwise.
    def test(n : UInt64) : Bool
      off, bit = off_bit(n)

      idx = @set.index { |el| el.offset == off }
      return false unless idx

      @set[idx].test(bit)
    end

    # each answers an instance of SbsIterator.
    #
    # Example usage:
    #   iter = set.each
    #   while (idx = iter.next()) != Iterator::Stop::INSTANCE
    #     ...
    #   end
    def each
      SbsIterator.new(@set.clone)
    end

    # clear_all resets this bitset.
    def clear_all() : BitSet
      @set.clear
      self
    end

    # clone answers a copy of this bitset.
    def clone : BitSet
      bs = BitSet.new()
      bs.raw_set.concat(@set)
      bs
    end

    # length answers the number of bits set.
    def length : UInt64
      popcountSet(@set)
    end

    # `==` answers `true` iff the given bitset has the same bits set as
    # those of this bitset.
    def ==(other : BitSet) : Bool
      return false if other.nil?
      return false if @set.length != other.raw_set.length
      return true if @set.length == 0

      @set.each_with_index do |el, i|
        oel = other.raw_set[i]
        return false if el.offset != oel.offset || el.bits != oel.bits
      end
      true
    end

    # prune removes empty blocks from this bitset.
    protected def prune()
      @set.delete_if { |el| el.bits == 0 }
    end

    # newSetOp generates several user-visible set operations.
    macro newSetOp(name, params)
      def {{ name.id }}(other : BitSet) : BitSet | Nil
        return nil if other.nil?

        res = BitSet.new()
        i, j = 0, 0
        while i < @set.length && j < other.raw_set.length
          sel, oel = @set[i], other.raw_set[j]

          case
          when sel.offset < oel.offset
            {% if params[:sfull] %}
            res.raw_set << sel
            {% end %}
            i += 1

          when sel.offset == oel.offset
            res.raw_set << Block.new(sel.offset, sel.bits {{ params[:op].id }} {{ params[:pre_op].id }}oel.bits)
            i, j = i+1, j+1

          else
            {% if params[:ofull] %}
            res.raw_set << oel
            {% end %}
            j += 1
          end
        end
        {% if params[:sfull] %}
        res.raw_set.concat(@set[i..-1])
        {% end %}
        {% if params[:ofull] %}
        res.raw_set.concat(other.raw_set[j..-1])
        {% end %}

        {% if params[:prune] %}
        res.prune()
        {% end %}
        res
      end
    end

    # difference performs a 'set minus' of the given bitset from this
    # bitset.
    newSetOp(:difference,
      {op: "&", pre_op: "~", sfull: true, ofull: false, prune: true})

    # intersection performs a 'set intersection' of the given bitset with
    # this bitset.
    newSetOp(:intersection,
      {op: "&", pre_op: "", sfull: false, ofull: false, prune: true})

    # union performs a 'set union' of the given bitset with this bitset.
    newSetOp(:union,
      {op: "|", pre_op: "", sfull: true, ofull: true, prune: false})

    # symmetric_difference performs a 'set symmetric difference' between
    # the given bitset and this bitset.
    newSetOp(:symmetric_difference,
      {op: "^", pre_op: "", sfull: true, ofull: true, prune: true})

    # difference! performs an in-place 'set minus' of the given bitset
    # from this bitset.
    def difference!(other : BitSet) : BitSet
      return self if other.nil?

      i, j = 0, 0
      while i < @set.length && j < other.raw_set.length
        sel, oel = @set[i], other.raw_set[j]

        case
        when sel.offset < oel.offset
          i += 1

        when sel.offset == oel.offset
          sel.bits &= ~oel.bits
          @set[i] = sel
          i, j = i+1, j+1

        else
          j += 1
        end
      end

      prune()
      self
    end

    # difference_cardinality answers the cardinality of the difference set
    # between this bitset and the given bitset.  This does *not* construct
    # an intermediate bitset.
    def difference_cardinality(other : BitSet) : UInt64
      return self.length if other.nil?

      c = 0_u64
      i, j = 0, 0
      while i < @set.length && j < other.raw_set.length
        sel, oel = @set[i], other.raw_set[j]

        case
        when sel.offset < oel.offset
          c += popcount(sel.bits)
          i += 1

        when sel.offset == oel.offset
          c += popcount(@set[i].bits & ~oel.bits)
          i, j = i+1, j+1

        else
          j += 1
        end
      end
      @set[i..-1].each { |el| c+= popcount(el.bits) }

      c
    end

    # intersection! performs a 'set intersection' of the given bitset with
    # this bitset, updating this bitset itself.
    def intersection!(other : BitSet) : BitSet
      return self if other.nil?

      i, j = 0, 0
      while i < @set.length && j < other.raw_set.length
        sel, oel = @set[i], other.raw_set[j]

        case
        when sel.offset < oel.offset
          sel.bits = 0_u64
          @set[i] = sel
          i += 1

        when sel.offset == oel.offset
          sel.bits &= oel.bits
          @set[i] = sel
          i, j = i+1, j+1

        else
          j += 1
        end
      end
      while i < @set.length
        sel = @set[i]
        sel.bits = 0_u64
        @set[i] = sel
        i += 1
      end

      prune()
      self
    end

    # intersection_cardinality answers the cardinality of the intersection
    # set between this bitset and the given bitset.  This does *not*
    # construct an intermediate bitset.
    def intersection_cardinality(other : BitSet) : UInt64
      return 0_u64 if other.nil?

      c = 0_u64
      i, j = 0, 0
      while i < @set.length && j < other.raw_set.length
        sel, oel = @set[i], other.raw_set[j]

        case
        when sel.offset < oel.offset
          i += 1

        when sel.offset == oel.offset
          c += popcount(@set[i].bits & oel.bits)
          i, j = i+1, j+1

        else
          j += 1
        end
      end

      c
    end

    # union! performs a 'set union' of the given bitset with this bitset,
    # updating this bitset itself.
    def union!(other : BitSet) : BitSet
      return self if other.nil?

      i, j = 0, 0
      loop do
        break if i >= @set.length || j >= other.raw_set.length

        sel, oel = @set[i], other.raw_set[j]

        case
        when sel.offset < oel.offset
          i += 1

        when sel.offset == oel.offset
          sel.bits |= oel.bits
          @set[i] = sel
          i, j = i+1, j+1

        else
          @set.insert(i, oel)
          i, j = i+1, j+1
        end
      end
      @set.concat(other.raw_set[j..-1])

      self
    end

    # union_cardinality answers the cardinality of the union
    # set between this bitset and the given bitset.  This does *not*
    # construct an intermediate bitset.
    def union_cardinality(other : BitSet) : UInt64
      return self.length if other.nil?

      c = 0_u64
      i, j = 0, 0
      while i < @set.length && j < other.raw_set.length
        sel, oel = @set[i], other.raw_set[j]

        case
        when sel.offset < oel.offset
          c += popcount(sel.bits)
          i += 1

        when sel.offset == oel.offset
          c += popcount(@set[i].bits | oel.bits)
          i, j = i+1, j+1

        else
          c += popcount(oel.bits)
          j += 1
        end
      end
      @set[i..-1].each { |el| c += popcount(el.bits) }
      other.raw_set[j..-1].each { |el| c += popcount(el.bits) }

      c
    end

    # symmetric_difference! performs a 'set symmetric difference' of the
    # given bitset with this bitset, updating this bitset itself.
    def symmetric_difference!(other : BitSet) : BitSet
      return self if other.nil?

      i, j = 0, 0
      while i < @set.length && j < other.raw_set.length
        sel, oel = @set[i], other.raw_set[j]

        case
        when sel.offset < oel.offset
          i += 1

        when sel.offset == oel.offset
          sel.bits ^= oel.bits
          @set[i] = sel
          i, j = i+1, j+1

        else
          @set.insert(i, oel)
          j += 1
        end
      end
      @set.concat(other.raw_set[j..-1])

      prune()
      self
    end

    # symmetric_difference_cardinality answers the cardinality of the
    # symmetric_difference set between this bitset and the given bitset.
    # This does *not* construct an intermediate bitset.
    def symmetric_difference_cardinality(other : BitSet) : UInt64
      return self.length if other.nil?

      c = 0_u64
      i, j = 0, 0
      while i < @set.length && j < other.raw_set.length
        sel, oel = @set[i], other.raw_set[j]

        case
        when sel.offset < oel.offset
          c += popcount(sel.bits)
          i += 1

        when sel.offset == oel.offset
          c += popcount(@set[i].bits ^ oel.bits)
          i, j = i+1, j+1

        else
          c += popcount(oel.bits)
          j += 1
        end
      end
      @set[i..-1].each { |el| c += popcount(el.bits) }
      other.raw_set[j..-1].each { |el| c += popcount(el.bits) }

      c
    end

    # complement answers a bit-wise complement of this bitset, up to the
    # highest bit set in this bitset.
    def complement : BitSet
      res = BitSet.new()
      return res if @set.length == 0

      off = 0_u64
      @set.each_with_index do |el, i|
        while off < el.offset
          res.raw_set << Block.new(off, ALL_ONES)
          off += 1
        end

        if i < @set.length-1
          res.raw_set << Block.new(el.offset, ~el.bits)
          off += 1
        end
      end
      res.raw_set << @set[-1]

      if res.raw_set.length > 0
        blk = res.raw_set[-1]
        j = 63
        while (1_u64 << j) & blk.bits == 0
          j -= 1
        end
        blk.bits = blk.bits << (63-j)
        blk.bits = ~blk.bits >> (63-j)
        res.raw_set[-1] = blk

        blk = res.raw_set[0]
        # '0'th bit should be ignored.
        blk.bits = blk.bits >> 1
        blk.bits = blk.bits << 1
        res.raw_set[0] = blk
      end

      res.prune()
      res
    end

    # all? answers `true` if all the bits in it, up to its highest set
    # bit, are set; answers `false` otherwise.
    def all? : Bool
      return false if @set.length == 0

      off = 0_u64
      @set[0..-2].each do |el|
        return false if el.offset != off
        return false if el.bits != ALL_ONES

        off += WORD_SIZE
      end

      # Check the last block.
      w = @set[-1].bits
      c = popcount(w)
      w = w >> c
      return false if w > 0
      true
    end

    # empty? answers `true` iff this bitset is empty, `false` otherwise.
    def empty? : Bool
      @set.length == 0
    end

    # none? is an alias for `empty?`.
    def none? : Bool
      empty?
    end

    # any? answers `true` iff this bitset is not empty, `false` otherwise.
    def any? : Bool
      !empty?
    end

    # superset? answers `true` if this bitset includes all of the elements
    # of the given bitset.
    def superset?(other : BitSet) : Bool
      return true if other.nil? || other.empty?

      other.difference_cardinality(self) == 0
    end

    # strict_superset? answers `true` if this bitset is a superset of the
    # given bitset, and includes at least one additional element.
    def strict_superset?(other : BitSet) : Bool
      return false if @set.length < other.raw_set.length
      return false if !superset?(other)

      length > other.length
    end
  end
end
