$:.unshift File.join(File.dirname(__FILE__), '..', 'app')
require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]

require 'boot'