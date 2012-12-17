module Spot
  class Player

    def self.state
      `./script/get-state`
    end

    def self.playing
      song = `./script/playing`.gsub /(?<!\n)\n(?!\n)/, ''
      "Now playing #{song}..."
    end

    def self.play
      `./script/play`
      self.playing
    end

    def self.pause
      `./script/pause`
      "Everything is paused."
    end
    
    def self.next
      `./script/next`
      "Onwards! #{self.playing}"
    end

    def self.back
      `./script/back`
      "Let's hear it again! #{self.playing}"
    end
    
    def self.mute
      `./script/mute`
      'Shhh...'
    end

    def self.volume
      `./script/get-volume`.gsub /(?<!\n)\n(?!\n)/, ''
    end
    
    def self.volume=(vol)
      `./script/set-volume #{vol}`
      vol
    end

    def self.play_song(spotifyTrack)
      `./script/play-song #{spotifyTrack}`
      self.playing
    end

  end
end