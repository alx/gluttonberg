require 'merb-auth-more/mixins/salted_user'

module Gluttonberg
  class User
    include DataMapper::Resource
    include Merb::Authentication::Mixins::SaltedUser
  
    property :id, Serial
    property :name, String, :length => 1..100
    property :email, String, :length => 1..100

    
  end
end
