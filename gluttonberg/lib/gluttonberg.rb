if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)

  load_dependency 'merb-slices'
  Merb::Plugins.add_rakefiles "gluttonberg/tasks/merbtasks", "gluttonberg/tasks/slicetasks", "gluttonberg/tasks/spectasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Default configuration
  Merb::Slices::config[:gluttonberg][:layout] ||= :gluttonberg
  
  # All Slice code is expected to be namespaced inside a module
  module Gluttonberg
    
    # Slice metadata
    self.description = "A content management system"
    self.version = "0.0.1"
    self.author = "Freerange Future (www.freerangefuture.com)"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
      Content.setup
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(Gluttonberg)
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    #
    # @note prefix your named routes with :gluttonberg_
    #   to avoid potential conflicts with global named routes.
    def self.setup_router(scope)
      # example of a named route
      scope.match('/index(.:format)').to(:controller => 'main', :action => 'index').name(:index)
    end
    
  end
  
  Gluttonberg.push_path(:models, Gluttonberg.root / "app" / "models")
  Gluttonberg.push_path(:observers, Gluttonberg.root / "app" / "observers")
  
  # Default directory layout
  Gluttonberg.setup_default_structure!
  
  # Third party dependencies
  dependency 'merb_datamapper'
  dependency 'dm-is-tree'
  dependency 'dm-observer'
  dependency 'dm-is-list'
  dependency 'dm-validations'
  dependency 'dm-timestamps'
  dependency 'dm-types'
  dependency 'merb-assets'
  dependency 'merb-helpers'

  # Various mixins and classes
  dependency "gluttonberg/content"
  dependency "gluttonberg/admin_controller"
  dependency "gluttonberg/public_controller"
  
end