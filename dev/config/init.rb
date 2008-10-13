$KCODE = 'UTF8'

use_orm :datamapper
use_test :rspec
use_template_engine :haml

Merb::Config.use do |c|  
  c[:session_id_key] = 'saywhat'
  c[:session_secret_key]  = 'cbdf5572c84cd403a94c32a68e50775f786c4f59'
  c[:session_store] = 'cookie'
end

file_path = File.dirname(__FILE__)

# Grab the correct environment config
require File.join(file_path, "environments/#{Merb.environment}")

# Connect to the DB
DataMapper.setup(:default, "sqlite3://#{File.join(file_path, "../db/#{Merb.environment}.db")}")