module Spot
  class Player
    
    def self.state
      `.script/get-state`
    end

    def self.playing
      song = `./script/playing`
      "Now playing #{song}..."
    end

    def self.play
      `./script/play`
      "Let's do it..."
      self.playing
    end

    def self.find(query)
      
    end

    def self.pause
      `./script/pause`
      "Everything is paused."
    end
    
    def self.next
      `./script/next`
      "Onwards!"
      self.playing
    end

    def self.back
      `./script/back`
      "Let's hear it again!"
    end
    
    def self.mute
      `./script/mute`
      'Shhh...'
    end

    def self.volume
      `./script/get-volume`
    end
    
    def self.volume=(vol)
      `./script/set-volume #{vol}`
      vol
    end

  private
   def self.play_song(spotifyTrack)
      `./script/play-song #{spotifyTrack}`
      self.playing
    end

  end
end