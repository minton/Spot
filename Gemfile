source 'https://rubygems.org'

gem 'sinatra'
gem 'rake'
gem 'foreman'
gem 'thin'
gem 'pry'
gem 'rspotify'

group :development do
  gem 'shotgun'
end

group :test do
  gem 'rspec'
  gem 'simplecov'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec'
  gem 'rack-test'
end
