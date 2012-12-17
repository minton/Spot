require 'models/player'
require 'models/spotify'

module Spot
  class App < Sinatra::Base
    get '/' do
      'Welcome to Spot bitches!'
    end
    put '/play' do
      Player.play
    end
    put '/pause' do
      Player.pause
    end
    put '/mute' do
      Player.mute
    end
    get '/playing' do
      Player.playing
    end
    put '/next' do
      Player.next
    end
    put '/back' do
      Player.back
    end
    get '/volume' do
      Player.volume.to_s
    end
    put  '/volume' do
      Player.volume = params[:volume]
      Player.volume.to_s
    end
    get '/find' do
      query = params[:q]  
      track_uri = Spotify.find(query)
      track_uri.nil?? "What the hell is you talkin' 'bout?" : track_uri
    end
  end
end