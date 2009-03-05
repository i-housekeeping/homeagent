at_exit do
  require "irb"
  require "drb/acl"
  require "sqlite3"
end

#load "script/server"

PORT = 3001


# Load the environment
require File.dirname(__FILE__)  + '/config/environment.rb'

# change the current directory
Dir.chdir File.dirname(__FILE__)

# Setup webrick 
puts "=> homeagent starting at http://localhost:#{PORT}/"
#webrick = mount(WEBrick::HTTPServer.new(:Port => PORT ))

#trap("INT") { $webrick.shutdown }



case RUBY_PLATFORM 
when /darwin/
  system("open http://localhost:#{PORT}")
when /win/
  system("start http://localhost:#{PORT}")
end

#webrick.start
#load "mongrel_rails service::install -N HomeAgent -c #{RAILS_ROOT} -p 3000 -e development"
load "script/server"
