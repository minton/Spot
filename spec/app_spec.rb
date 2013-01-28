require 'spec_helper'

module Spot
  describe App do
    describe "GET /" do
      it "should return a welcome" do
        get "/"
        last_response.should be_ok
      end 
    end
  end
end