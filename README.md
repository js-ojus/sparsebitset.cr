<!--
   (c) Copyright 2015 JONNALAGADDA Srinivas

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-->

[![Build Status](https://travis-ci.org/js-ojus/sparsebitset.cr.svg?branch=master)](https://travis-ci.org/js-ojus/sparsebitset.cr)

### SparseBitSet

`SparseBitSet` is a port of my Go `sparsebitset` implementation.  The description here is excerpted from the `README` of that project.

A simple implementation of sparse bitsets for non-negative integers.

The representation is very simple, and uses a sequence of (offset, bits) pairs.  It is similar to that of Go's `x/tools/container/intsets` and Java's `java.util.BitSet`.

The original motivation for `sparsebitset` comes from a need to store custom indexes of documents in a database.  Accordingly, `sparsebitset` trades CPU time for space.

### Installation

Add this line to your application's `Projectfile`:

```crystal
deps do
  github "js-ojus/sparsebitset.cr"
end
```

### Usage

```crystal
require "sparsebitset"
```

### Contributing

1. Fork it ( https://github.com/js-ojus/sparsebitset.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
