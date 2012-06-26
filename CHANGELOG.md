## Version 1.0


### 2012-06 - Version 1.0.1-pre: First wave of refactors


* `Collection` no longer has factory functionality. 


### 2012-04 - Version 1.0.0-pre: DSL Magic

#### New functionality

* `pathname/path_to`            -- templated file paths
* `serialization/to_zaml`       -- predictable, structured YAML writer
* `test_helpers/capture_output` -- swallows $stdout/$stderr for testing purposes

#### Renamed

* moved `gorillib/serialization` to `gorillib/serialization/to_wire`
* renamed `datetime/flat` to `datetime/to_flat`

#### Removed:

* `receiver` and `receiver/*`                 -- see `property` and others
* `hash/tree_merge` and `hashlike/tree_merge` -- use overlays
* `hash/indifferent_access`                   -- use `mash`
* `metaprogramming/cattr_accessor`            -- use `class_attribute`
* `metaprogramming/mattr_accessor`            -- discouraged
* `struct/*`                                  -- discouraged

## Version 0.x

### 2011-12-11 - Version 0.1.8: Gemfile fixes; Log.dump shows caller

* Gorillib has no real dependencies on spork, rcov, Redcloth, etc; these are only useful for rake tasks. Dialed down the urgency of version req's on rspec, yard, etc, and moved the esoterica (spork, rcov, watchr, RedCloth) into bundler groups. Bundler will still install them if you 'bundle install' from the gorillib directory, but the gemspec no longer forces upstream requirers to consider them dependencies
* Log.dump adds the immediate caller to the end of its output
* fix to Gemfile so that early versions of jruby don't hate on it

### 2011-08-21 - Version 0.1.6: Serialization and DeepHash

* Serialization with #to_wire -- like #to_hash, but hands #to_wire down the line to any element that contains it (as opposed to `#to_hash`, which should just do that)
* Hashlike#tree_merge: combined into the one version; gave it a block in the middle to do any fancy footwork
* deep_hash -- allows dotted (a.b.c) access to a nested hash
* Array#random_element -- gets a random member of the array.

Will soon be deprecating Receiver, in favor of the far more powerful Icss::ReceiverModel in the icss library.

### 2011-06-29 - Version 0.1.3: Fancier receivers

* can now mix activemodel into a receiver, getting all its validation and other awesomeness
* added receiver_model as an experimental 'I'm a fancy cadillac-style receiver'

### 2011-06-24 Version 0.1.2: Receiver body fixes

* Better @Object.try@ (via active_support)
* Receiver body can now be an interpolated string or a hash; this lets you use anonymous classes. Added tuple methods (does an in-order traversal).
* Bugfix for inclusion order in ActsAsHash

### Version 0.1.0: Hashlike refactor, Receiver arrives

v0.1.0 brings:

* Receiver module
* refeactoring of hash decorations into a new hashlike class
* ability to inject hashlike behavior into Struct

### Version 0.0.7: full test coverage!

        lib/
        |-- gorillib.rb
        `-- gorillib
            |-- array
            |   |-- compact_blank.rb
            |   |-- deep_compact.rb
            |   `-- extract_options.rb
            |-- base.rb
            |-- datetime
            |   |-- #flat.rb#
            |   |-- flat.rb
            |   `-- parse.rb
            |-- enumerable
            |   `-- sum.rb
            |-- hash
            |   |-- compact.rb
            |   |-- deep_compact.rb
            |   |-- deep_merge.rb
            |   |-- keys.rb
            |   |-- reverse_merge.rb
            |   |-- slice.rb
            |   `-- zip.rb
            |-- logger
            |   `-- log.rb
            |-- metaprogramming
            |   |-- aliasing.rb
            |   |-- cattr_accessor.rb
            |   |-- class_attribute.rb
            |   |-- delegation.rb
            |   |-- mattr_accessor.rb
            |   |-- remove_method.rb
            |   `-- singleton_class.rb
            |-- numeric
            |   `-- clamp.rb
            |-- object
            |   |-- blank.rb
            |   |-- try.rb
            |   `-- try_dup.rb
            |-- some.rb
            `-- string
                |-- constantize.rb
                |-- human.rb
                |-- inflections.rb
                `-- truncate.rb

