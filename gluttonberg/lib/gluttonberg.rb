if defined?(Merb::Plugins)

  merb_version = "1.0"
  datamapper_version = "0.9.6"

  $:.unshift File.dirname(__FILE__)

  load_dependency 'merb-slices', merb_version
  Merb::Plugins.add_rakefiles "gluttonberg/tasks/merbtasks", "gluttonberg/tasks/slicetasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Default configuration
  Merb::Slices::config[:gluttonberg] = {
    :layout         => :gluttonberg,
    :localize       => true,
    :translate      => true,
    :encode_dialect => :url,
    :encode_locale  => :url,
    :template_dir   => Merb.root / "templates"
  }.merge!(Merb::Slices::config[:gluttonberg])
  
  # All Slice code is expected to be namespaced inside a module
  module Gluttonberg
    
    # Slice metadata
    self.description = "A content management system"
    self.version = "0.0.1"
    self.author = "Freerange Future (www.freerangefuture.com)"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
      Helpers.setup
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
      Content.setup
      Library.setup
      Templates.setup

      Merb::Authentication.user_class = Gluttonberg::User
      Merb::Authentication.activate!(:default_password_form)
      Merb::Plugins.config[:"merb-auth"][:login_param] = "email"
      Merb::Authentication.class_eval do 
        def store_user(user)
          return nil unless user 
          user.id
        end
        def fetch_user(session_info)
          User.get(session_info)
        end
      end
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(Gluttonberg)
    def self.deactivate
    end
    
    def self.setup_router(scope)
      Gluttonberg::Router.setup(scope)
    end
    
   # Bunch of methods related to the configuration
   def self.localized_and_translated?
      config[:localize] && config[:translate]
   end
   
    def self.localized?
      config[:localize]
    end
    
    def self.translated?
      config[:translate]
    end
  end
  
  Gluttonberg.push_path(:models, Gluttonberg.root / "app" / "models")
  unless Merb.environment == 'test'
    Gluttonberg.push_path(:observers, Gluttonberg.root / "app" / "observers")
  end
  
  # Default directory layout
  Gluttonberg.setup_default_structure!
  
  # Third party dependencies
  dependency 'merb-assets',     merb_version
  dependency 'merb-helpers',    merb_version
  dependency 'merb_datamapper', merb_version
  dependency 'dm-aggregates',   datamapper_version
  dependency 'dm-is-tree',      datamapper_version
  dependency 'dm-observer',     datamapper_version
  dependency 'dm-is-list',      datamapper_version
  dependency 'dm-validations',  datamapper_version
  dependency 'dm-timestamps',   datamapper_version
  dependency 'dm-types',        datamapper_version
  dependency 'merb-auth-core',  merb_version
  dependency 'merb-auth-more',  merb_version do
    require 'merb-auth-more/mixins/redirect_back'
  end
  dependency 'RedCloth',        "4.1.0",  {:require_as => 'redcloth'}
  
  # Stdlib dependencies
  require 'digest/sha1'

  # Various mixins and classes
  require "gluttonberg/content"
  require "gluttonberg/library"
  require "gluttonberg/router"
  require "gluttonberg/admin_controller"
  require "gluttonberg/public_controller"
  require "gluttonberg/core_ext"
  require "gluttonberg/datamapper_ext"
  require "gluttonberg/templates"
  require "gluttonberg/components"
  require "gluttonberg/helpers"
  
end