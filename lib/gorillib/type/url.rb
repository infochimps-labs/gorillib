require 'addressable/uri'

class ::Url < Addressable::URI ; end

class UrlFactory < Gorillib::Factory::ConvertingFactory
  self.product = ::Url
  def convert(obj)      product.parse(obj) ; end
  register_factory!
end
