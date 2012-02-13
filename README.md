
## Gorillib: infochimps' lightweight subset of ruby convenience methods

We love the conveniences provided by `active_support` and `extlib`, we just don't love them at the same time and on top of each other. active_support is slow to load, has many dependencies, and is all intertwingled. We had too many collisions between `active_support` 2.x and 3.x and `extlib`. 

What gorillib gives you is clarity over what features are brought in. If you want to *just* get `Object#blank?`, just `require 'gorillib/object/blank'`. No dependencies, no codependents.

* No creep: include only what you need
* No dependencies unless audaciously advertised.
* Upwards compatible with `active_record` and `extlib`
  - the `active_support` components have significantly more robust internationalization, and some functions have rich option sets in `active_support` vs. basic functionality in `gorillib`.  So the rule is if you were happy with `gorillib` you'll be happy with `active_support`, but not vice-versa.

### require 'gorillib/receiver'

Gorillib has at least one powerful addition to the canon: the receiver mixin.

* lightweight
* gives you weak type safety but doesn't jack around with setters/getters.
* object/hash semantics
  
### require 'gorillib'

* require 'gorrillib/base'

### require 'gorillib/base'

requires the following libraries:

* gorillib/object/blank
* gorillib/hash/reverse_merge
* gorillib/hash/compact
* gorillib/array/compact_blank
* gorillib/object/try

### require 'gorillib/some'

requires @gorillib/base@ and the following additional libraries:

* gorillib/logger/log.rb
* set
* time
* date
* gorillib/array/extract_options
* gorillib/enumerable/sum
* gorillib/datetime/flat
* gorillib/datetime/parse
* gorillib/hash/zip
* gorillib/hash/slice
* gorillib/hash/keys
* gorillib/metaprogramming/class_attribute
* gorillib/metaprogramming/cattr_accessor
* gorillib/metaprogramming/singleton_class
* gorillib/metaprogramming/remove_method

---------------------------------------------------------------------------

### gorillib/array

* *gorrillib/array/extract_options*
  - Array       extract_options!
  - Hash        extractable_options? (helper method)
* *gorrillib/array/compact_blank*
  - Array       compact_blank, compact_blank!
* *gorrillib/array/deep_compact*
  - Array       deep_compact, deep_compact!

### gorillib/datetime

* *gorillib/datetime/flat*
  - Date, Time	to_flat
* *gorillib/datetime/parse*
  - Time        parse_safely

### gorillib/enumerable

* *gorillib/enumerable/sum*
  - Enumerable  sum
  
### gorillib/hash

* *gorillib/hash/compact*
  - Hash        compact, compact!, compact_blank, compact_blank!
* *gorrilib/hash/deep_compact*
  - Hash        deep_compact, deep_compact!
* *gorrilib/hash/deep_merge*
  - Hash        deep_merge, deep_merge!
* *gorillib/hash/keys*
  - Hash        stringify_keys, stringify_keys!, symbolize_keys, symbolize_keys!
  - Hash        assert_valid_keys
* *gorillib/hash/reverse_merge*
  - Hash        reverse_merge, reverse_merge!
* *gorillib/hash/slice*
  - Hash        slice, slice!, extract!
* *gorillib/hash/zip*
  - Hash        Hash.zip

### gorillib/logger

* *gorillib/logger/log*
  - Unless the top-level constant ::Log has been defined, opens a new Logger to STDERR and assigns it to ::Log

### gorillib/metaprogramming

* *gorillib/metaprogramming/aliasing*
  - alias_method_chain
* *gorillib/metaprogramming/class_attribute*
  - Class       class_attribute
* *gorillib/metaprogramming/remove_method* _required with class_attribute_
  - Module      remove_possible_method, redefine_method
* *gorillib/metaprogramming/singleton_class* _required with class_attribute_
  - Kernel      singleton_class
* *gorillib/metaprogramming/cattr_accessor*
  - Class#      cattr_reader, cattr_writer, cattr_accessor
* *gorillib/metaprogramming/mattr_accessor*
  - Class#      mattr_reader, mattr_writer, mattr_accessor
* *gorillib/metaprogramming/delegation*
  - Module#     delegate

### gorillib/numeric

* *gorillib/numeric/clamp*
  - Numeric     clamp -- coerce a number to lie within a certain min/max

### gorillib/object

* *gorillib/object/blank*
  - Object      blank?, present?  (and specialized for all other classes)
* *gorillib/object/try*
  - Object      try
* *gorillib/object/try_dup*
  - Object      try_dup

### gorillib/string

* *gorillib/string/constantize*
  - String	constantize
* *gorillib/string/inflections*:
  - String	camelize
  - String	snakeize
  - String	underscore
  - String	demodulize
* *gorillib/string/human*
  - String	titleize
  - String	humainze
  - Array	as_sentence
* *gorillib/string/truncate*
  - String	truncate

---------------------------------------------------------------------------

## Maybe and No

#### Maybe

* *Mash*
* *Receiver*
* *Struct*
* *gorillib/string/escaping*: _DEPENDENCIES_: htmlentities, addressable/uri
  - String	 xml_escape
  - String	 url_escape
  - String	 escape_regexp, unescape_regexp
* *extlib/module/find_const*
  - Module      find_const

#### No

* String        classify -- this singularizes. You want camelize unless you're in ActiveSupport
* Object        tap     isn't necessary -- included in 1.8.7+
* Symbol        to_proc isn't necessary -- included in 1.8.7+
* Class         class_inheritable_attribute -- use class_attribute instead
* Object        to_flat on anything but Time and Date -- poorly-defined
* Object        returning -- deprecated in favor of #tap

---------------------------------------------------------------------------

## Credits & Copyright

Most of this code is ripped from active_support and extlib -- their license
carries over. Everything else is Copyright (c) 2011 Infochimps. See LICENSE.txt
for further details.

