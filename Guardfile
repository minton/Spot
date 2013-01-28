# More info at https://github.com/guard/guard#readme

guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { "spec" }
  watch('app/app.rb') { "spec" }
  watch('app/models/(.+)\.rb')  { |m| "spec/#{m[1]}_spec.rb" }
end