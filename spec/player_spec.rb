require 'spec_helper'

module Spot
  describe Player do
    it { Player.should respond_to(:state) }
    it { Player.should respond_to(:playing) }
    it { Player.should respond_to(:artwork) }
    it { Player.should respond_to(:play) }
    it { Player.should respond_to(:pause) }
    it { Player.should respond_to(:next) }
    it { Player.should respond_to(:back) }
    it { Player.should respond_to(:mute) }
    it { Player.should respond_to(:volume) }
    it { Player.should respond_to(:play_song) }
  end
end