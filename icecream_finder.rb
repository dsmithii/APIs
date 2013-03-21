require 'nokogiri'
require 'json'
require 'rest-client'
require 'addressable/uri'


# location -> icecream

#1. Geocodin API - geocode current location
#2. Places API - input icecream string and our lat/long
#3. Directions API - get directions between self and icream. This will use
#Nokogiri to parse the Directions API HTML output

#https://maps.googleapis.com/maps/api/place/nearbysearch/output?=ice+cream&
#
#http://maps.googleapis.com/maps/api/geocode/json?address=160+Folsom+Street,+San+Francisco,+CA&sensor=false

geocode = Addressable::URI.new(
  :scheme => "http",
  :host => "maps.googleapis.com",
  :path => "/maps/api/geocode/json",
  :query_values => {:address => "160 Folsom Street, San Francisco, CA",
                     :sensor => "false"
                    }
  ).to_s

geocode_response = JSON.parse(RestClient.get(geocode))

lat = geocode_response["results"][0]["geometry"]["location"]["lat"]
lng = geocode_response["results"][0]["geometry"]["location"]["lng"]

address = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "/maps/api/place/nearbysearch/json",
   :query_values => {:location => "#{lat},#{lng}",
   :radius => "500",
   :types => "food",
   :sensor => "false",
   :keyword => "ice cream",
   :key => "AIzaSyCMhm4ls9-IkjpROwmUwOBHuVnN1l_zFrs"}
 ).to_s

places_response = JSON.parse(RestClient.get(address))

icecream_locations = places_response["results"].map do |place|
  place["geometry"]["location"]
end

icecream_names = places_response["results"].map do |place|
  place["name"]
end

directions_URLs = []

icecream_locations.each_with_index do |location|
    latt, long = location['lat'], location['lng']
    shop = "#{latt},#{long}"
    directions = Addressable::URI.new(
      :scheme => "http",
      :host => "maps.googleapis.com",
      :path => "/maps/api/directions/json",
      :query_values => {:origin => "#{lat},#{lng}",
      :destination => shop,
      :sensor => "false",
      :mode => "walking",

                      }
  ).to_s

  directions_URLs << directions
end

direction_parses = []
directions_URLs.each do |url|
  direction_parses << JSON.parse(RestClient.get(url))
end

text_directions_array = []
direction_parses.each_with_index do |json_parse, i|
  directions = icecream_names[i] + "\n"
  json_parse["routes"][0]["legs"][0]["steps"].each do |step|
    directions += Nokogiri::HTML(step["html_instructions"]) #doc.at('Destination').content = "'\n'Destination")
    directions += "\n"
  end
  directions += "\n"
  text_directions_array << directions
end

puts text_directions_array


