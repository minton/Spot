require 'meta-spotify'

module Spot
  class Spotify
    #Search spotify meta db for tracks with name like query.
    #Excludes non-US tracks.
    #Orders by popularity.
    def self.find(query)
        search = MetaSpotify::Track.search(query)
        tracks = search.first[1]
        tracks.select! {|i| i.album.available_territories.include?('us') || i.album.available_territories.include?('worldwide') }
        tracks.sort! {|x,y| y.popularity <=> x.popularity }
        tracks.length > 0 ? tracks[0].uri : nil
    end
  end
end