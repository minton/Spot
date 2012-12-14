require 'models/player'

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
    put '/find' do
      query = params[:q]  
      Player.find(query)    
    end
  end
end