## Questions

* for unset attributes, could return UnsetNull (descendent of NullObject)

ICSS: 
* If a class explicitly inherits from an ICSS class `Geo::Whatever < Geo::Place`, does the new class have a new schema? I think so


## Goals:

* lightweight -- enabling `field :foo, Integer` doesn't include everything & the kitchen sink.
* supports attr_accessor-like fields and DSL-like fields
* cascading type conversion
* no magic on initialize, getters or setters
* can be mixed in to a Hash-like (get/set elements) or a normal object (get/set instance variables)
* compatible with ActiveModel
* compatible with Avro
* no `method_missing`
* methods are inscribed on an included module, so you can override and call `super`.

A model class    has fields
A model instance has attributes that correspond to those fields

    `.receive`            .new, #receive!
    `#receive!`           `receive_attribute` on each attribute in the hash; `receive_remaining` on the leftovers
    `#receive_attribute`  type converts val, calls `write_attribute`
    `#receive_remaining`  nothing; may be overridden.
    
    `#read_attribute`
    `#write_attribute`
    `#unset_attribute`
  
    `#_read_attribute`    no callbacks etc
    `#_write_attribute`   no callbacks, dirty, validation etc

### Features

* field
  - create Field object, add it to class' fields
  - get meta_module
  - inscribe methods: setter, getter, set?; receiver
* defaults
* validation, including required attributes
* type conversion
* dsl fields

later:

* hooks
* sort ordering
* aliasing


##### Unified substrate

can work with

- hashlike      (`#[]`, `#[]=`, `#delete`)
- instance vars (`instance_variable_get`, `instance_variable_set`, `remove_instance_variable`)
- methods       (send, send, raise error if unset is called)

what is in a hash-like representation?

    fields defined in class
    attributes hash with all field's names as keys
    attributes hash with values that have been set only
    methods
    if hash, its keys

    has_key?
    each_pair
    to_hash
    #[], #[]=, #delete, #keys

##### Type conversion:

* method on class
* separate factory set

* want a reasonable and non-magical default
* want to be able to override sensibly
  - `nil` for string is `nil` vs `nil` for string is `''`
  - boolean from `0` is false vs true






## Types

These are types:

        ruby type       kind            avro type       json type       example
        ----------      --------        ---------       ---------       ---------
        NilClass        simple          null            null            nil
        Boolean         simple          boolean         boolean         true
        Integer         simple          int,long        integer         1
        Float           simple          float,double    number          1.1
        String          simple          bytes           string          "\u00FF"
        String          simple          string          string          "foo"
        Time            simple          time            string          "2011-01-02T03:04:05Z"
        
        RecordType      named           record          object          {"a": 1}
        Enum            named           enum            string          "FOO"
        Array           container       array           array           [1]
        Hash            container       map             object          { "a": 1 }
        String          container       fixed           string          "\u00ff"
        XxxFactory      union           union           object          
            
These are schemata:


        ruby type       example
        ----------      -----------------------------------------
        NamedSchema     [parent class for schema]
        
        PrimitiveSchema { type:"string" }
        RecordSchema    { type:"record", name:"", fields:[...] }
        EnumSchema      
        ArraySchema           
        HashSchema            
        FixedSchema          
        UnionSchema


a type:
* is represented as a ruby class
  
  - so the class is `< RecordType` and instances are `is_a?(RecordType)`

a schema
  - a class `is_a?(RecordSchema)`
  
__________________________________________________________________________  

a record type (eg `Geo::Place`):
* is a class
* `extend RecordSchema`, giving the class itself
  - `field`: define a new field
  - `fields`, `field_names`: enumerate fields
  and from `NamedSchema`,
  - `metamodel`
  - `schema`: a class inheritable 
* `include RecordType`, giving its instances 
  - `attributes`:  map from field names to values
  - `read_attribute`, `write_attribute`, `unset_attribute`, and `attribute_set?`
  - `==`: two records are equal if they have the same class and same attributes
* `include Meta::Geo::PlaceType`
  - `{foo}`, `{foo}=`: call `read_attribute` and `write_attribute` resp.
  - `receive_foo`: type converts, then calls `write_attribute`

#### Receive (type conversion)

* `.receive` calls new with all given args, returns obj.
  - **question**: `create`?
  - has to go through `initialize`: required and default declarations get fucked up if you create an object without giving it a base set of attributes

* model initializer
  - calls `#update`, `super`

* `.receivable?`: responds to `#attributes` or to (`#each_pair` and `has_key?`).
* `coerce`: prepares a type-coerced attribute hash: for each field, calls `field.coerce` if the source value exists (using indifferent access),

* instance `#receive!` 
  - for each field, calls `#receive_{foo}` if the source value exists (using indifferent access)
  - accepts anything `receivable?`
  - (we must either use UnsetNull or add a `#existing_attributes` or something)
  - does not matter if the source object has a method named for the field.
  - **question**: is `rcvr_remaining` callback always received?
  - **question**: `after_receive` -- defined directly? or use callbacks?
* `#receive_foo(val)`
  - gets the received instance by calling `.receive` on the field's type
  - **question** ... or should it call a method on the field
  - calls `write_attribute` 

**alternative**: 

* `.receive` 
  - first arg must be a `receivable?` object
  - `coerce` the receivable into an initializer-ready attribute hash
  - calls `initialize` with that attribute hash and any other args
  
* `#receive!`  

The question largely revolves around gating. What are the touchpoints?
* `update` / `merge`
* `receive` / `receive!`
* `initialize`

* at what point do we need the context of the object to be around
  - insists that typecasting happen in isolation of object, which seems fair.
* 

* can you assign nil to a required field?


#### Factories

http://objectsonrails.com/#sec-5-2

        setter injection to strategize how Blog objects create new entries:

        class Blog
          # ...
          attr_writer :post_factory
          # ...
          private
          def post_factory
            @post_factory ||= Post.public_method(:new)
          end
        end

> #public_method, if you're unfamiliar with it, instantiates a call-able Method object. When the object's #call method is invoked it will be as if we called the named method on the original object. The "public" in the name refers to the fact that unlike #method, #public_method respects public/private boundaries and will not generate a Method object for a private method.



#### Default Values for Attributes

**question**: defaults are either
* late-resolved: read_attribute falls through to the field.default if unset. An attribute is unset until it is explicitly written, even if it has a default.
* late-resolved, persistent: read_attribute falls through to the field.default if unset; value is then set on the attribute. Yuck.
* callback-resolved: attribute is set to its field's default value in a callback (maybe `after_receive`). 
  - A field with a default may not be `unset`.
  
The Layer feature allows late-resolved values, so I lean towards callback-resolved. 
The question there is what lifecycle event triggers default setting:
* `initialize` -- means we have to chain the initializer.
  - if a value is unset
* `update`     -- yuck
* `receive!`   -- means you can have an object that has been initialized but no defaults. However, you do get 


I think the `super` method of initialize should set the default values. They will be clobbered in any further receive call.

Setting default values
Defaults can be set via the :default key for a property. They can be static values, such as 12 or "Hello", but DataMapper also offers the ability to use a Proc to set the default value. The property becomes whatever the Proc returns, which will be called the first time the property is used without having first set a value. The Proc itself receives two arguments: The resource the property is being set on, and the property itself.

#### Validation of Attributes


#### ICSS Schema

* has methods
  - `klass`
  - `namespace`
  - `fullname`, `pathname`, `basename`
  - `type`: one of `:record`, `:array`, etc. (**question**: should this be `schema`?)
  - `doc`
  - `fields`
  - `is_a`
  - `doc_hints`
  - `core?`
  - `make` -- manufactures class representing type

schema describes properties of the type

a schema is either

* a string, naming a defined type;
* an 
* a class embodying the defined type
* an object of the form

        { "type": (typename), ... attributes ... }
