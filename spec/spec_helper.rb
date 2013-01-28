$:.unshift File.join(File.dirname(__FILE__), '..', 'app')
require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]

require 'boot'
require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Spot::App
end