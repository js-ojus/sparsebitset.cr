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

  # Constants used in `popcount`.
  M1  = 0x5555555555555555_u64
  M2  = 0x3333333333333333_u64
  M4  = 0x0f0f0f0f0f0f0f0f_u64
  H01 = 0x0101010101010101_u64

  # popcount answers the number of bits set to `1` in this word.  It
  # uses the bit population count (Hamming Weight) logic taken from
  # https://en.wikipedia.org/wiki/Hamming_weight#Efficient_implementation.
  private def popcount(x : UInt64) : UInt64
    x -= (x >> 1) & M1
    x  = (x & M2) + ((x >> 2) & M2)
    x  = (x + (x >> 4)) & M4
    (x * H01) >> 56
  end

  # popcount_set answers the number of bits set to `1` in the given set.
  private def popcount_set(set : Array(Block)) : UInt64
    set.inject(0_u64) do |cnt, el|
      cnt + popcount(el.bits)
    end
  end

  #

  DE_BRUIJN = UInt8[0, 1, 56, 2, 57, 49, 28, 3, 61, 58, 42, 50, 38,
                    29, 17, 4, 62, 47, 59, 36, 45, 43, 51, 22, 53, 39, 33, 30, 24, 18,
                    12, 5, 63, 55, 48, 27, 60, 41, 37, 16, 46, 35, 44, 21, 52, 32, 23,
                    11, 54, 26, 40, 15, 34, 20, 31, 10, 25, 14, 19, 9, 13, 8, 7, 6,]

  # A quick way to find the number of trailing zeroes in the word.
  private def trailing_zeroes_count(v : UInt64) : UInt64
    (DE_BRUIJN[(((0_u64-v) & v) * 0x03f79d71b4ca8b09) >> 58]).to_u64
  end

  #

  # Block is a pair of (offset, bits) capable of holding information for up
  # to `WORD_SIZE` elements.
  struct Block
    getter offset
    property bits

    def initialize(@offset : UInt64, @bits : UInt64)
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
    include SparseBitSet

    def initialize(@set : Array(Block))
      @curr = 0_u64
    end

    # next answers the position of the next bit that is set.  If no such
    # bit exists, it answers `Iterator::Stop::INSTANCE`.
    def next : UInt64 | Iterator::Stop
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

    # next answers the position of the next set bit in this bitset,
    # starting with the given index.  If no such bit exists, it
    # answers `Iterator::Stop::INSTANCE`.
    def next(n : UInt64) : UInt64 | Iterator::Stop
      c = popcount_set(@set)
      return Iterator::Stop::INSTANCE if n > c

      @curr = n
      self.next
    end
  end

  # BitSet is a compact representation of sparse sets of non-negative
  # integers.
  struct BitSet
    include Iterable
    include SparseBitSet

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

    # size answers the number of bits set.
    def size : UInt64
      popcount_set(@set)
    end

    # `==` answers `true` iff the given bitset has the same bits set as
    # those of this bitset.
    def ==(other : BitSet) : Bool
      return false if @set.size != other.raw_set.size
      return true if @set.size == 0

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

    # def_set_op generates several user-visible set operations.
    macro def_set_op(name, params)
      def {{ name.id }}(other : BitSet) : BitSet
        res = BitSet.new()
        i, j = 0, 0
        while i < @set.size && j < other.raw_set.size
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
    def_set_op(:difference,
               {op: "&", pre_op: "~", sfull: true, ofull: false, prune: true})

    # intersection performs a 'set intersection' of the given bitset with
    # this bitset.
    def_set_op(:intersection,
               {op: "&", pre_op: "", sfull: false, ofull: false, prune: true})

    # union performs a 'set union' of the given bitset with this bitset.
    def_set_op(:union,
               {op: "|", pre_op: "", sfull: true, ofull: true, prune: false})

    # symmetric_difference performs a 'set symmetric difference' between
    # the given bitset and this bitset.
    def_set_op(:symmetric_difference,
               {op: "^", pre_op: "", sfull: true, ofull: true, prune: true})

    # def_inp_set_op generates several user-visible set operations.
    macro def_inp_set_op(name, params)
      def {{ name.id }}!(other : BitSet) : BitSet
        i, j = 0, 0
        while i < @set.size && j < other.raw_set.size
          sel, oel = @set[i], other.raw_set[j]

          case
          when sel.offset < oel.offset
            {% if params[:empty] %}
              sel.bits = 0_u64
              @set[i] = sel
            {% end %}
            i += 1

          when sel.offset == oel.offset
            sel.bits {{ params[:op].id }}= {{ params[:pre_op].id }}oel.bits
            @set[i] = sel
            i, j = i+1, j+1

          else
            {% if params[:full] %}
              @set.insert(i, oel)
              i += 1
            {% end %}
            j += 1
          end
        end
        {% if params[:empty] %}
          while i < @set.size
            sel = @set[i]
            sel.bits = 0_u64
            @set[i] = sel
            i += 1
          end
        {% elsif params[:full] %}
          @set.concat(other.raw_set[j..-1])
        {% end %}

        prune()
        self
      end
    end

    # difference! performs an in-place 'set minus' of the given bitset
    # from this bitset.
    def_inp_set_op(:difference,
                  {op: "&", pre_op: "~", empty: false, full: false})

    # intersection! performs a 'set intersection' of the given bitset with
    # this bitset, updating this bitset itself.
    def_inp_set_op(:intersection,
                   {op: "&", pre_op: "", empty: true, full: false})

    # union! performs a 'set union' of the given bitset with this bitset,
    # updating this bitset itself.
    def_inp_set_op(:union,
                   {op: "|", pre_op: "", empty: false, full: true})

    # symmetric_difference! performs a 'set symmetric difference' of the
    # given bitset with this bitset, updating this bitset itself.
    def_inp_set_op(:symmetric_difference,
                   {op: "^", pre_op: "", empty: false, full: true})

    # def_set_count generates several user-visible set operations.
    macro def_set_count(name, params)
      def {{ name.id }}_cardinality(other : BitSet) : UInt64
        c = 0_u64
        i, j = 0, 0
        while i < @set.size && j < other.raw_set.size
          sel, oel = @set[i], other.raw_set[j]

          case
          when sel.offset < oel.offset
            {% if params[:sfull] %}
              c += popcount(sel.bits)
            {% end %}
            i += 1

          when sel.offset == oel.offset
            c += popcount(@set[i].bits {{ params[:op].id }} {{ params[:pre_op].id }}oel.bits)
            i, j = i+1, j+1

          else
            {% if params[:ofull] %}
              c += popcount(oel.bits)
            {% end %}
            j += 1
          end
        end
        {% if params[:sfull] %}
          @set[i..-1].each { |el| c += popcount(el.bits)}
        {% end %}
        {% if params[:ofull] %}
          other.raw_set[j..-1].each { |el| c += popcount(el.bits) }
        {% end %}

        c
      end
    end

    # difference_cardinality answers the cardinality of the difference set
    # between this bitset and the given bitset.  This does *not* construct
    # an intermediate bitset.
    def_set_count(:difference,
                  {op: "&", pre_op: "~", sfull: true, ofull: false})

    # intersection_cardinality answers the cardinality of the intersection
    # set between this bitset and the given bitset.  This does *not*
    # construct an intermediate bitset.
    def_set_count(:intersection,
                  {op: "&", pre_op: "", sfull: false, ofull: false})

    # union_cardinality answers the cardinality of the union
    # set between this bitset and the given bitset.  This does *not*
    # construct an intermediate bitset.
    def_set_count(:union,
                  {op: "|", pre_op: "", sfull: true, ofull: true})

    # symmetric_difference_cardinality answers the cardinality of the
    # symmetric_difference set between this bitset and the given bitset.
    # This does *not* construct an intermediate bitset.
    def_set_count(:symmetric_difference,
                  {op: "^", pre_op: "", sfull: true, ofull: true})

    # complement answers a bit-wise complement of this bitset, up to the
    # highest bit set in this bitset.
    #
    # N.B. Since bitset is not bounded, `a.complement().complement() != a`.
    # This limits the usefulness of this operation.  Use with care!
    def complement : BitSet
      res = BitSet.new()
      return res if @set.size == 0

      off = 0_u64
      @set.each_with_index do |el, i|
        while off < el.offset
          res.raw_set << Block.new(off, ALL_ONES)
          off += 1
        end

        if i < @set.size-1
          res.raw_set << Block.new(el.offset, ~el.bits)
          off += 1
        end
      end
      res.raw_set << @set[-1]

      blk = res.raw_set[-1]
      j = 1
      while (blk.bits >> j) > 0
        j += 1
      end
      blk.bits = blk.bits << (64-j)
      blk.bits = ~blk.bits >> (64-j)
      res.raw_set[-1] = blk

      # '0'th bit should be ignored.
      blk = res.raw_set[0]
      blk.bits = blk.bits >> 1
      blk.bits = blk.bits << 1
      res.raw_set[0] = blk

      res.prune()
      res
    end

    # all? answers `true` if all the bits in it, up to its highest set
    # bit, are set; answers `false` otherwise.
    def all? : Bool
      return false if @set.size == 0

      off = 0_u64
      @set.each_with_index do |el, i|
        return false if el.offset != off

        if el.offset > 0 && i < @set.size-1
          return false if el.bits != ALL_ONES
        end

        off += 1
      end

      el = @set[-1]
      cp = popcount(el.bits)
      if el.offset == 0 # Handle '0'th bit.
        cp += 1
        w = (el.bits | 1) ^ ALL_ONES
      else
        w = el.bits ^ ALL_ONES
      end
      tz = trailing_zeroes_count(w)
      return false if cp != tz

      true
    end

    # empty? answers `true` iff this bitset is empty, `false` otherwise.
    def empty? : Bool
      @set.size == 0
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
      return true if other.empty?

      other.difference_cardinality(self) == 0
    end

    # strict_superset? answers `true` if this bitset is a superset of the
    # given bitset, and includes at least one additional element.
    def strict_superset?(other : BitSet) : Bool
      return false if @set.size < other.raw_set.size
      return false if !superset?(other)

      size > other.size
    end
  end
end
