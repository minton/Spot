require 'spec_helper'
require 'pry'

module Spot
  describe App do
    describe "GET /" do
      it "should greet us" do
        get "/"
        expect(last_response).to be_ok
        expect(last_response.body).to include("Spot")
      end
    end
  end
end