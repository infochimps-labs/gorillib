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


type   corresponds to class
schema describes properties of the type

a schema is either

* a string, naming a defined type;
* an 
* a class embodying the defined type
* an object of the form

        { "type": (typename), ... attributes ... }
