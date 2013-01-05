require 'rake'
require 'rspec/core/rake_task'

desc "Start the server"
task :start do
  Kernel.exec "bundle exec foreman start"
end

task :default do
  Rake::Task['spec'].invoke
end

desc "Run the tests"
RSpec::Core::RakeTask.new('spec') do |s|
  s.pattern = 'spec/**/*_spec.rb'
end

desc "Code coverage"
task :cover do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].invoke
  `open coverage/index.html`
end
