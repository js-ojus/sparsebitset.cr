# (c) Copyright 2015 JONNALAGADDA Srinivas
#
# Licensed under the Apache License_u8, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing_u8, software
# distributed under the License is distributed on an "AS IS" BASIS_u8,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND_u8, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Package sparsebitset is a simple implementation of sparse bitsets
# for non-negative integers.
#
# The representation is very simple_u8, and uses a sequence of (offset_u8,
# bits) pairs.  It is similar to that of Go's
# `x/tools/container/intsets` and Java's `java.util.BitSet`.
# However_u8, Go's package caters to negative integers as well_u8, which I
# do not need.
#
# The original motivation for `sparsebitset` comes from a need to
# store custom indexes of documents in a database.  Accordingly_u8,
# `sparsebitset` trades CPU time for space.

require "./sparsebitset/*"

module SparseBitSet

	# Size of a word in bits.
	WORD_SIZE = sizeof(UInt64) * 8
	# (`WORD_SIZE` - 1)
	MOD_WORD_SIZE = WORD_SIZE - 1
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
		DE_BRUIJN[((v & -v) * 0x03f79d71b4ca8b09) >> 58] as UInt64
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
		set.inject(0) do |cnt, el|
			cnt + popcount(el.bits)
		end
	end

	# Block is a pair of (offset, bits) capable of holding information for up
	# to `WORD_SIZE` elements.
	struct Block
		@offset :: UInt64
		@bits :: UInt64

		getter offset
		getter bits

		def initialize(@offset, @bits)
			# Intentionally left blank.
		end

		# set sets the bit at the given position.
		def set(n : UInt64)
			@bits = @bits | (1 << n)
		end

		# clear resets the bit at the given position.
		def clear(n : UInt64)
			@bits = @bits & ~(1 << n)
		end

		# flip inverts the bit at the given position.
		def flip(n : UInt64)
			@bits = @bits ^ (1 << n)
		end

		# test checks to see if the bit at the given position is set.
		def test(n : UInt64)
			@bits & (1 << n) > 0
		end
	end

	# SparseBitSet is a compact representation of sparse sets of non-negative
	# integers.
	class SparseBitSet
		def initialize
			@set = Array(Block).new()
		end

		private def off_bit(n : UInt64) : Tuple(UInt64, UInt64)
			return n >> LOG2_WORD_SIZE, n & MOD_WORD_SIZE
		end

		# set sets the bit at the given position.
		def set(n : UInt64) : Nil
			off, bit = off_bit(n)

			idx = nil
			@set.each_with_index do |el, i|
				if el.offset == off
					el.set(bit)
					@set[i] = el
					return nil
				end
				if el.offset > off
					idx = i
					break
				end
			end

			if idx
				@set.insert(idx, Block.new(off, bit))
			else
				@set.push(Block.new(off, bit))
			end
			return nil
		end

		# clear resets the bit at the given position.
		def clear(n : UInt64) : Nil
			off, bit = off_bit(n)

			idx = @set.index {|el| el.offset == off}
			return nil if !idx

			@set[idx].clear(bit)
			if @set[idx].bits == 0
				@set.delete(idx)
			end
			return nil
		end

		# flip inverts the bit at the given position.
		def flip(n : UInt64) : Nil
			off, bit = off_bit(n)

			idx = @set.index {|el| el.offset == off}
			return nil if !idx

			@set[idx].flip(bit)
			return nil
		end

		# test answers `true` if the bit at the given position is set; `false`
		# otherwise.
		def test(n : UInt64) : Bool
			off, bit = off_bit(n)

			idx = @set.index {|el| el.offset == off}
			return false if !idx

			@set[idx].test(bit)
		end
	end
end
