# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gorillib}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Infochimps"]
  s.date = %q{2011-06-07}
  s.description = %q{Gorillib: infochimps lightweight subset of ruby convenience methods}
  s.email = %q{coders@infochimps.org}
  s.extra_rdoc_files = [
    "LICENSE.textile",
    "README.textile"
  ]
  s.files = [
    ".gitignore",
    ".rspec",
    "CHANGELOG.textile",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.textile",
    "README.textile",
    "Rakefile",
    "VERSION",
    "gorillib.gemspec",
    "lib/gorillib.rb",
    "lib/gorillib/array/compact_blank.rb",
    "lib/gorillib/array/deep_compact.rb",
    "lib/gorillib/array/extract_options.rb",
    "lib/gorillib/base.rb",
    "lib/gorillib/datetime/flat.rb",
    "lib/gorillib/datetime/parse.rb",
    "lib/gorillib/enumerable/sum.rb",
    "lib/gorillib/hash/compact.rb",
    "lib/gorillib/hash/deep_compact.rb",
    "lib/gorillib/hash/deep_dup.rb",
    "lib/gorillib/hash/deep_merge.rb",
    "lib/gorillib/hash/indifferent_access.rb",
    "lib/gorillib/hash/keys.rb",
    "lib/gorillib/hash/reverse_merge.rb",
    "lib/gorillib/hash/slice.rb",
    "lib/gorillib/hash/tree_merge.rb",
    "lib/gorillib/hash/zip.rb",
    "lib/gorillib/hashlike.rb",
    "lib/gorillib/hashlike/compact.rb",
    "lib/gorillib/hashlike/deep_compact.rb",
    "lib/gorillib/hashlike/deep_dup.rb",
    "lib/gorillib/hashlike/deep_merge.rb",
    "lib/gorillib/hashlike/hashlike_via_accessors.rb",
    "lib/gorillib/hashlike/keys.rb",
    "lib/gorillib/hashlike/reverse_merge.rb",
    "lib/gorillib/hashlike/slice.rb",
    "lib/gorillib/hashlike/tree_merge.rb",
    "lib/gorillib/logger/log.rb",
    "lib/gorillib/metaprogramming/aliasing.rb",
    "lib/gorillib/metaprogramming/cattr_accessor.rb",
    "lib/gorillib/metaprogramming/class_attribute.rb",
    "lib/gorillib/metaprogramming/delegation.rb",
    "lib/gorillib/metaprogramming/mattr_accessor.rb",
    "lib/gorillib/metaprogramming/remove_method.rb",
    "lib/gorillib/metaprogramming/singleton_class.rb",
    "lib/gorillib/numeric/clamp.rb",
    "lib/gorillib/object/blank.rb",
    "lib/gorillib/object/try.rb",
    "lib/gorillib/object/try_dup.rb",
    "lib/gorillib/receiver.rb",
    "lib/gorillib/receiver/active_model_shim.rb",
    "lib/gorillib/receiver/acts_as_hash.rb",
    "lib/gorillib/receiver/acts_as_loadable.rb",
    "lib/gorillib/receiver/tree_diff.rb",
    "lib/gorillib/receiver/validations.rb",
    "lib/gorillib/some.rb",
    "lib/gorillib/string/constantize.rb",
    "lib/gorillib/string/human.rb",
    "lib/gorillib/string/inflections.rb",
    "lib/gorillib/string/truncate.rb",
    "lib/gorillib/struct/acts_as_hash.rb",
    "lib/gorillib/struct/hashlike_iteration.rb",
    "notes/fancy_hashes_and_receivers.textile",
    "notes/hash_rdocs.textile",
    "spec/array/compact_blank_spec.rb",
    "spec/array/extract_options_spec.rb",
    "spec/datetime/flat_spec.rb",
    "spec/datetime/parse_spec.rb",
    "spec/enumerable/sum_spec.rb",
    "spec/hash/compact_spec.rb",
    "spec/hash/deep_compact_spec.rb",
    "spec/hash/deep_merge_spec.rb",
    "spec/hash/indifferent_access_spec.rb",
    "spec/hash/keys_spec.rb",
    "spec/hash/reverse_merge_spec.rb",
    "spec/hash/slice_spec.rb",
    "spec/hash/zip_spec.rb",
    "spec/hashlike/behave_same_as_hash_spec.rb",
    "spec/hashlike/hashlike_behavior_spec.rb",
    "spec/hashlike/hashlike_via_accessors_fuzzing_spec.rb",
    "spec/hashlike/hashlike_via_accessors_spec.rb",
    "spec/hashlike_spec.rb",
    "spec/logger/log_spec.rb",
    "spec/metaprogramming/aliasing_spec.rb",
    "spec/metaprogramming/cattr_accessor_spec.rb",
    "spec/metaprogramming/class_attribute_spec.rb",
    "spec/metaprogramming/delegation_spec.rb",
    "spec/metaprogramming/mattr_accessor_spec.rb",
    "spec/metaprogramming/singleton_class_spec.rb",
    "spec/numeric/clamp_spec.rb",
    "spec/object/blank_spec.rb",
    "spec/object/try_dup_spec.rb",
    "spec/object/try_spec.rb",
    "spec/receiver/acts_as_hash_spec.rb",
    "spec/receiver_spec.rb",
    "spec/spec_helper.rb",
    "spec/string/constantize_spec.rb",
    "spec/string/human_spec.rb",
    "spec/string/inflections_spec.rb",
    "spec/string/inflector_test_cases.rb",
    "spec/string/truncate_spec.rb",
    "spec/struct/acts_as_hash_fuzz_spec.rb",
    "spec/struct/acts_as_hash_spec.rb",
    "spec/support/hashlike_fuzzing_helper.rb",
    "spec/support/hashlike_helper.rb",
    "spec/support/hashlike_struct_helper.rb",
    "spec/support/hashlike_via_delegation.rb",
    "spec/support/kcode_test_helper.rb",
    "spec/support/matchers/be_array_eql.rb",
    "spec/support/matchers/be_hash_eql.rb",
    "spec/support/matchers/enumerate_method.rb",
    "spec/support/matchers/evaluate_to_true.rb"
  ]
  s.homepage = %q{http://infochimps.com/labs}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{include only what you need. No dependencies, no creep}
  s.test_files = [
    "spec/array/compact_blank_spec.rb",
    "spec/array/extract_options_spec.rb",
    "spec/datetime/flat_spec.rb",
    "spec/datetime/parse_spec.rb",
    "spec/enumerable/sum_spec.rb",
    "spec/hash/compact_spec.rb",
    "spec/hash/deep_compact_spec.rb",
    "spec/hash/deep_merge_spec.rb",
    "spec/hash/indifferent_access_spec.rb",
    "spec/hash/keys_spec.rb",
    "spec/hash/reverse_merge_spec.rb",
    "spec/hash/slice_spec.rb",
    "spec/hash/zip_spec.rb",
    "spec/hashlike/behave_same_as_hash_spec.rb",
    "spec/hashlike/hashlike_behavior_spec.rb",
    "spec/hashlike/hashlike_via_accessors_fuzzing_spec.rb",
    "spec/hashlike/hashlike_via_accessors_spec.rb",
    "spec/hashlike_spec.rb",
    "spec/logger/log_spec.rb",
    "spec/metaprogramming/aliasing_spec.rb",
    "spec/metaprogramming/cattr_accessor_spec.rb",
    "spec/metaprogramming/class_attribute_spec.rb",
    "spec/metaprogramming/delegation_spec.rb",
    "spec/metaprogramming/mattr_accessor_spec.rb",
    "spec/metaprogramming/singleton_class_spec.rb",
    "spec/numeric/clamp_spec.rb",
    "spec/object/blank_spec.rb",
    "spec/object/try_dup_spec.rb",
    "spec/object/try_spec.rb",
    "spec/receiver/acts_as_hash_spec.rb",
    "spec/receiver_spec.rb",
    "spec/spec_helper.rb",
    "spec/string/constantize_spec.rb",
    "spec/string/human_spec.rb",
    "spec/string/inflections_spec.rb",
    "spec/string/inflector_test_cases.rb",
    "spec/string/truncate_spec.rb",
    "spec/struct/acts_as_hash_fuzz_spec.rb",
    "spec/struct/acts_as_hash_spec.rb",
    "spec/support/hashlike_fuzzing_helper.rb",
    "spec/support/hashlike_helper.rb",
    "spec/support/hashlike_struct_helper.rb",
    "spec/support/hashlike_via_delegation.rb",
    "spec/support/kcode_test_helper.rb",
    "spec/support/matchers/be_array_eql.rb",
    "spec/support/matchers/be_hash_eql.rb",
    "spec/support/matchers/enumerate_method.rb",
    "spec/support/matchers/evaluate_to_true.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0.12"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.7"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_development_dependency(%q<spork>, ["~> 0.9.0.rc5"])
      s.add_development_dependency(%q<RedCloth>, [">= 0"])
      s.add_development_dependency(%q<rcov>, [">= 0.9.9"])
      s.add_development_dependency(%q<watchr>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.12"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.7"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_development_dependency(%q<rcov>, [">= 0.9.9"])
      s.add_development_dependency(%q<spork>, ["~> 0.9.0.rc5"])
      s.add_development_dependency(%q<watchr>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0.12"])
      s.add_dependency(%q<yard>, ["~> 0.6.7"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_dependency(%q<spork>, ["~> 0.9.0.rc5"])
      s.add_dependency(%q<RedCloth>, [">= 0"])
      s.add_dependency(%q<rcov>, [">= 0.9.9"])
      s.add_dependency(%q<watchr>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.12"])
      s.add_dependency(%q<yard>, ["~> 0.6.7"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_dependency(%q<rcov>, [">= 0.9.9"])
      s.add_dependency(%q<spork>, ["~> 0.9.0.rc5"])
      s.add_dependency(%q<watchr>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0.12"])
    s.add_dependency(%q<yard>, ["~> 0.6.7"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rspec>, ["~> 2.5.0"])
    s.add_dependency(%q<spork>, ["~> 0.9.0.rc5"])
    s.add_dependency(%q<RedCloth>, [">= 0"])
    s.add_dependency(%q<rcov>, [">= 0.9.9"])
    s.add_dependency(%q<watchr>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.12"])
    s.add_dependency(%q<yard>, ["~> 0.6.7"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rspec>, ["~> 2.5.0"])
    s.add_dependency(%q<rcov>, [">= 0.9.9"])
    s.add_dependency(%q<spork>, ["~> 0.9.0.rc5"])
    s.add_dependency(%q<watchr>, [">= 0"])
  end
end

