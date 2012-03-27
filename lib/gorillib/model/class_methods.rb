module Gorillib
  #
  #
  # class
  module Model
    #
    # Endows the model class with
    # * klass.field  -- adds a field
    # * klass.fields -- list of record_fields
    #
    module ClassMethods

      #
      # Describes a field in a Record object.
      #
      # Each field has the following attributes:
      #
      # @param [Symbol] name -- name of the field (required)
      #
      # @param [Class] type -- type to receive this field
      #
      # @option schema [String] :doc -- description of field for users (optional)
      #
      def field field_name, type, schema={}
      end

      #
      #     ruby type   kind        avro type     json type   example
      #     ----------  --------    ---------     ---------   ---------
      #     NilClass    simple      null          null        nil
      #     Boolean     simple      boolean       boolean     true
      #     Integer     simple      int,long      integer     1
      #     Float       simple      float,double  number      1.1
      #     String      simple      bytes         string      "\u00FF"
      #     String      simple      string        string      "foo"
      #     RecordModel named       record        object      {"a": 1}
      #     Enum        named       enum          string      "FOO"
      #     Array       container   array         array       [1]
      #     Hash        container   map           object      { "a": 1 }
      #     String      container   fixed         string      "\u00ff"
      #     XxxFactory  union       union         object
      #     Time        simple      time          string      "2011-01-02T03:04:05Z"
      #
      # @option schema [Object] :default -- a default value for this field, used
      #   when reading instances that lack this field (optional).
      #   Permitted values depend on the field's schema type, according to the
      #   table below. Default values for union fields correspond to the first
      #   schema in the union. Default values for bytes and fixed fields are
      #   JSON strings, where Unicode code points 0-255 are mapped to unsigned
      #   8-bit byte values 0-255.
      #
      # @option schema [String] :order -- specifies how this field impacts sort
      #   ordering of this record (optional).
      #   Valid values are "ascending" (the default), "descending", or
      #   "ignore". For more details on how this is used, see the the sort
      #   order section below.
      #
      # @option schema [Boolean] :required -- same as :validates => :presence
      #
      # @option schema [Hash] :validates -- sends the validation on to
      #   Icss::Type::Validations. Uses syntax parallel to ActiveModel's:
      #
      # @option schema [Symbol] :accessor -- with +:none+, no accessor is
      #   created. With +:protected+, +:private+, or +:public+, applies
      #   corresponding access rule.
      #
      #      :presence     => true
      #      :uniqueness   => true
      #      :numericality => true
      #      :length       => { :minimum => 0, maximum => 2000 }
      #      :format       => { :with => /.*/ }
      #      :inclusion    => { :in => [1,2,3] }
      #      :exclusion    => { :in => [1,2,3] }
      #

    end
  end
end
