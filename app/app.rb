require 'models/player'
require 'models/spotify'

module Spot
  class App < Sinatra::Base
    get '/' do
      'Welcome to Spot!<br/>http://github.com/minton/Spot'
    end
    put '/play' do
      Player.volume = 45
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
    post '/find' do
      query = params[:q]  
      track_uri = Spotify.find(query)
      if track_uri.nil? 
        "What the hell is you talkin' 'bout?"
      else
        Player.play_song(track_uri)
      end 
    end
    get '/playing.png' do
      content_type 'image/png'
      img = Player.artwork
      send_file img, :disposition => 'inline'
    end
  end
end