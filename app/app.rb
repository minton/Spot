require 'models/player'
require 'models/spotify'
require 'logger'

module Spot
  class App < Sinatra::Base
    
    configure do
      enable :logging
      `./script/boot`
    end

    get '/' do
      'Welcome to Spot!<br/>http://github.com/minton/Spot'
    end

    put '/say' do
      what = params[:what]
      Player.say(what)
    end

    put '/shipit' do
      Player.shipit
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
      Player.volume = params[:volume].to_i and Player.volume.to_s unless params[:volume].nil?
    end

    put '/bumpup' do
      Player.volume = bump_up_volume.to_i
      Player.volume.to_s
    end

    put '/bumpdown' do
      Player.volume = Player.volume - bump_down_volume.to_i
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

    private

      def bump_up_volume
        current_volume = Player.volume
        case current_volume
        when 0..10
          20
        when 11..30
          current_volume*1.45
        when 31..70
          current_volume*1.25
        else
          current_volume*1.1
        end
      end

      def bump_down_volume
        current_volume = Player.volume
        case current_volume
        when 100..80
          current_volume*0.3
        when 79..40
          current_volume*0.2
        else
          current_volume*0.1
        end
      end
      
  end
end
