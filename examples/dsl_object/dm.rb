require 'dm-core'

DataMapper.setup(:default, :adapter => 'in_memory')

class Foo
  include DataMapper::Resource

  property :id,   Serial
  property :name, Text
end

f = Foo.new
f.name = "foo"
f.save

puts f.inspect
