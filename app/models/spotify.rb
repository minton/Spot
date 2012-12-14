require 'meta-spotify'

module Spot
  class Spotify
    def self.find(query)
      begin
        search = MetaSpotify::Track.search(query)
        tracks = search.first[1]
        tracks.select! {|i| i.album.available_territories.include?('us') || i.album.available_territories.include?('worldwide') }
        tracks.select! {|i| i.name.include?(query) }
        tracks.sort! {|x,y| y.popularity <=> x.popularity }

        noDups = {}
        tracks.each do |t|
          key = "#{t.name}.#{t.artists.first.name}"
          noDups[key] = t unless noDups.include?(key)
        end
        inspect noDups
        # if noDups.length == 1
        #   noDups[1].uri
        # else
        #   tracks = noDups.collect {|h| h[1] }
        #   noDups.each_pair { |k, v| puts "Found #{k}" }
        #   tracks.collect! {|t| "#{t.name} by #{t.artists.first.name} (#{t.uri})"}
        #   "Whoa! Lots of matches. Copy the spotify-track of the one you want: " + tracks.join("\n")
        # end
      rescue
        "Turns out the world doesn't know about that. Weird."
        $!.message
      end
    end
  end
end