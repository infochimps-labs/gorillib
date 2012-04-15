module Gorillib::Model
  class Name < String
    attr_accessor :namespace
    attr_reader   :singular, :element, :collection, :partial_path, :param_key, :i18n_key

    alias_method :cache_key, :collection

    class_attribute :inflector
    self.inflector ||= Gorillib::String::Inflector

    def initialize(klass, namespace = nil, name = nil)
      name ||= klass.name
      raise ArgumentError, "Class name cannot be blank. You need to supply a name argument when anonymous class given" if name.blank?

      super(name)

      @klass          = klass
      @singular       = _singularize(self).freeze
      @element        = inflector.underscore(inflector.demodulize(self)).freeze
      @human          = inflector.humanize(@element).freeze
      @i18n_key       = inflector.underscore(self).to_sym
      #
      self.namespace  = namespace
      self.plural     = inflector.pluralize(@singular)
    end

    def plural=(str)
      @plural         = str.dup.freeze
      @collection     = inflector.underscore(@plural).freeze
      @partial_path   = "#{@collection}/#{@element}".freeze
      str
    end

    def namespace=(ns)
      if ns.present?
        @unnamespaced = self.sub(/^#{ns.name}::/, '')
        @param_key    = _singularize(@unnamespaced).freeze
      else
        @unnamespaced = nil
        @param_key    = @singular.freeze
      end
    end

    def singular_route_key
      inflector.singularize(route_key).freeze
    end

    def route_key
      rk = (namespace ? inflector.pluralize(param_key) : plural.dup)
      rk << "_index" if plural == singular
      rk.freeze
    end

  private

    def _singularize(string, replacement='_')
      inflector.underscore(string).tr('/', replacement)
    end
  end

  # == Active Model Naming
  #
  # Creates a +model_name+ method on your object.
  #
  # To implement, just extend ActiveModel::Naming in your object:
  #
  #   class BookCover
  #     extend ActiveModel::Naming
  #   end
  #
  #   BookCover.model_name        # => "BookCover"
  #   BookCover.model_name.human  # => "Book cover"
  #
  #   BookCover.model_name.i18n_key              # => :book_cover
  #   BookModule::BookCover.model_name.i18n_key  # => :"book_module/book_cover"
  #
  # Providing the functionality that ActiveModel::Naming provides in your object
  # is required to pass the Active Model Lint test. So either extending the provided
  # method below, or rolling your own is required.
  module Naming
    # Returns a Name object for module, which can be used to retrieve all kinds
    # of naming-related information.
    def model_name
      @_model_name ||= Gorillib::Model::Name.new(self, namespace)
    end
  end
end
