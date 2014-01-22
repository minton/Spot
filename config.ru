require File.expand_path(File.dirname(__FILE__) + '/app/boot')

set :static, true
set :public_folder, 'public'

map('/') {
	run Spot::App
}