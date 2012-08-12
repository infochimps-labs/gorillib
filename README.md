# Gorillib: infochimps' lightweight subset of ruby convenience methods

We love the conveniences provided by `active_support` and `extlib`, we just don't love them at the same time and on top of each other. active_support is slow to load, has many dependencies, and is all intertwingled. We had too many collisions between `active_support` 2.x and 3.x and `extlib`.

What gorillib gives you is clarity over what features are brought in. If you want to *just* get `Object#blank?`, just `require 'gorillib/object/blank'`. No dependencies, no codependents.

* No creep: include only what you need
* No dependencies unless audaciously advertised.
* Upwards compatible with `active_record` and `extlib`
  - the `active_support` components have significantly more robust internationalization, and some functions have rich option sets in `active_support` vs. basic functionality in `gorillib`.  So the rule is if you were happy with `gorillib` you'll be happy with `active_support`, but not vice-versa.

### require 'gorillib/model

Gorillib has at least one powerful addition to the canon: the `Gorillib::Model` mixin.

Think of it like 'An ORM for JSON'. It's designed for data that spends as much time on the wire as it does in action -- things like API handlers or clients, data processing scripts, wukong jobs.

* lightweight
* serializes to/from JSON, TSV or plain hashes
* type converts when you need it, but doesn't complicate normal accessors
* upward compatible with ActiveModel

### require 'gorillib'

Requires only the following minimal set of libraries:

* `gorillib/object/blank`          -- fluent boolean methods `foo.blank?` & `foo.present?`
* `gorillib/array/extract_options` -- get optional keyword args from a `*args` signature
* `gorillib/hash/reverse_merge`    -- 
* `gorillib/hash/compact`
* `gorillib/array/compact_blank`
* `gorillib/exception/raisers`     -- DRY exceptions: `ArgumentError.check_arity!`, `TypeMismatchError`, 

### require 'gorillib/some'

requires @gorillib/base@ and the following additional libraries:

* `gorillib/logger/log.rb`
* `set`
* `time`
* `date`
* `gorillib/array/extract_options`
* `gorillib/enumerable/sum`
* `gorillib/datetime/flat`
* `gorillib/datetime/parse`
* `gorillib/hash/zip`
* `gorillib/hash/slice`
* `gorillib/hash/keys`
* `gorillib/metaprogramming/class_attribute`
* `gorillib/metaprogramming/cattr_accessor`
* `gorillib/metaprogramming/singleton_class`
* `gorillib/metaprogramming/remove_method`

__________________________________________________________________________

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

__________________________________________________________________________

## Colophon

### Credits & Copyright

Most of this code is ripped from active_support and extlib -- their license
carries over. Everything else is Copyright (c) 2011 Infochimps. See LICENSE.md
for further details.

### Issues, Patches and Pull Requests

Find this repo useful? Thanks! We love you! Find this repo *nearly* useful? Awesome! We'd love to have your help improving it. One way to help is to file an articulate well-reasoned bug report, feature proposal, or short story about gorillib on the [Gorillib issue tracker](http://github.com/infochimps-labs/gorillib/issues). An even better way to help is to create a Patch or Pull Request

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, but please do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send a pull request to github.com/infochimps-labs
* If you'd like, drop a line to the mailing list for infochimps open-source projects, infochimps-code@googlegroups.com

You might enjoy reading:

* [Style Guide for Ruby](https://github.com/infochimps-labs/style_guide/blob/master/style-guide-ruby.md)
* [Style Guide for README files](https://github.com/infochimps-labs/style_guide/blob/master/style-guide-for-readme-files.md) (aka our README README)
* [Style Guide for Repo Organization](https://github.com/infochimps-labs/style_guide/blob/master/style-guide-for-repo-organization.md)
* [The Name of the Wind](http://www.patrickrothfuss.com/content/books.asp), by Patrick Rothfuss.

(Don't let the existence of a style guide -- or really any sense of modesty -- keep you from submitting a patch. If it departs from the norm we'll either fix it up, or in some cases propose tweaks, but at least others hitting the same issue can enjoy its benefits. We'd rather have worky code with a section that reads like cobol-accented perl than something broken)