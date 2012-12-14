require 'meta-spotify'

module Spot
  class Spotify
    def find(query)
      begin
        search = MetaSpotify::Track.search(query)
        tracks = search.first[1]
        songs = []
        tracks.each |t| do
          songs << t.uri unless t.album.available_territories.include('nl')
        end
      rescue
        "Turns out the world doesn't know about that. Weird."
      end
    end
  end
end