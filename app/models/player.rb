module Spot
  class Player

    def self.state
      `./script/get-state`
    end

    def self.playing
      song = `./script/playing`.gsub /(?<!\n)\n(?!\n)/, ''
      "Now playing #{song}..."
    end

    def self.playingUri
      uri = `./script/playing-uri`
      uri
    end

    def self.artwork
      art = `./script/artwork`.gsub /(?<!\n)\n(?!\n)/, ''
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
      vol = `./script/get-volume`.gsub /(?<!\n)\n(?!\n)/, ''
      vol.to_i
    end
    
    def self.how_much_longer
      `./script/how-much-longer`
    end

    def self.volume=(vol)
      vol+=1
      `./script/set-volume #{vol}`
      vol
    end

    def self.play_song(spotifyTrack)
      `./script/play-song #{spotifyTrack}`
      sleep(0.5) #hack because it often sends back the info from the previously playing song
      self.playing
    end

    def self.say(what)
      currentVolume = self.volume
      self.volume=currentVolume/3
      `say #{what}`
      self.volume = currentVolume
      what
    end

  end
end
