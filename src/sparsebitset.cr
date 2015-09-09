# (c) Copyright 2015 JONNALAGADDA Srinivas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Package sparsebitset is a simple implementation of sparse bitsets
# for non-negative integers.
#
# The representation is very simple, and uses a sequence of (offset,
# bits) pairs.  It is similar to that of Go's
# `x/tools/container/intsets` and Java's `java.util.BitSet`.
# However, Go's package caters to negative integers as well, which I
# do not need.
#
# The original motivation for `sparsebitset` comes from a need to
# store custom indexes of documents in a database.  Accordingly,
# `sparsebitset` trades CPU time for space.

require "./sparsebitset/*"

module SparseBitSet
  # TODO Put your code here
end
