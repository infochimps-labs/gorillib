class Place
  include Gorillib::Record
  # fields can be simple...
  field :name, String
  field :country_id, String, :doc => 'Country code (2-letter alpha) containing the place'
  # ... or complext
  field :geo, GeoCoordinates, :doc => 'geographic location of the place'
end
class GeoCoordinates
  include Gorillib::Record
  field :latitude,  Float, :doc => 'latitude in decimal degrees; negative numbers are south of the equator'
  field :longitude, Float, :doc => 'longitude in decimal degrees; negative numbers are west of Greenwich'
end

# It's simple to instantiate complex nested data structures
lunch_spot = Place.receive({ :name => "Torchy's Tacos", :country_id => "us",
  :geo => { :latitude => "30.295", :longitude => "-97.745" }})
