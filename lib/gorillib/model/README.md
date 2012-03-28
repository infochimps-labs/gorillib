## Goals:

* lightweight -- if you only want to say `field :foo, Integer` you don't need to get the kitchen sink.
* supports attr_accessor-like fields and DSL-like fields
* cascading type conversion
* no magic on initialize, getters or setters
* can be mixed in to a Hash-like (get/set elements) or a normal object (get/set instance variables)
* compatible with ActiveModel
* compatible with Avro
* no method_missing


### Features

* `field` to define an attribute
* attribute defaults
* model validation, including required attributes
* type conversion
* hooks
* sort ordering
* 


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
