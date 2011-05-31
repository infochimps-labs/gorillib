
BASE_HSH                     = { :a  => 100, :b  => 200, :c => 300, :nil_val => nil, :false_val => false }.freeze
HASH_TO_TEST_HASHLIKE_STRUCT = { :a  => 100, :b  => 200, :c => 300, :nil_val => nil, :false_val => false, :new_key => nil, }.freeze
BASE_HSH_WITH_ARRAY_VALS     = { :a => [100,111], :b => 200, :c => [1, [2, 3, [4, 5, 6]]] }.freeze
BASE_HSH_WITH_ARRAY_KEYS     = {[:a,:aa] => 100,  :b => 200, [:c,:cc] => [300,333],  [1, 2, [3, 4]] => [1, [2, 3, [4, 5, 6]]] }.freeze
