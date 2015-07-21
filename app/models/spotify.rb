module Spot
  class Spotify
    #Search spotify meta db for tracks with name like query.
    #Excludes non-US tracks.
    #Orders by popularity.
    def self.find(query)
      data = self.find_data(query)
      data.nil? ? nil : data.uri
    end

    def self.find_data(query)
      tracks = self.find_tracks(query)
      tracks.length > 0 ? tracks.first : nil
    end

    def self.find_tracks(query, limit)
      tracks = RSpotify::Track.search(query, limit: limit, market: 'US')
      tracks.sort_by{|track| -track.popularity}
    end

    def self.get_album_info(uri)
      uri = uri.gsub("spotify:album:","")
      RSpotify::Album.find(uri)
    end

  end
end