require 'spec_helper'

module Spot
  describe App do
    describe "GET /" do
      it "should greet us" do
        get "/"
        last_response.should be_ok
        last_response.body.should == "Welcome to Spot!<br/>http://github.com/minton/Spot"
      end 
    end
  end
end