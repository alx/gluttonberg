require 'rubygems'
require 'merb-core'
require 'spec' # Satisfies Autotest and anyone else not using the Rake tasks
require 'dm-sweatshop'

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')
require File.join(File.dirname(__FILE__), "spec_fixtures")

DataMapper.auto_migrate!

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end
