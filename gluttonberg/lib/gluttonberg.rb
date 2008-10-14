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
      Library.setup
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(Gluttonberg)
    def self.deactivate
    end
    
    def self.setup_router(scope)
      scope.identify DataMapper::Resource => :id do |s|
        # Controllers in the content module
        s.match("/content").to(:controller => "content/main").name(:content)
        s.match("/content") do |c|
          c.resources(:pages, :controller => "content/pages") do |p| 
            p.match("/localizations/:id").to(:controller => "content/page_localizations") do |l|
              l.match("/edit").to(:action => "edit").name(:edit_localization)
              l.match(:method => "put").to(:action => "update")
            end.name(:localization)
          end
          c.resources(:templates, :controller => "content/templates") do |t|
            t.resources(:sections, :controller => "content/template_sections")
          end
        end
      
        # Top level controllers
        s.resources(:locales)
        s.resources(:dialects)
      
        # Asset Library
        s.match("/library").to(:controller => "library/main").name(:library)
        s.match("/library") do |a|
          a.resources(:assets, :controller => "library/assets")
          a.resources(:collections, :controller => "library/collections")
        end
      
        # Users
        s.match("/users").to(:controller => "users").name(:users)
      
        # Settings
        s.match("/settings").to(:controller => "settings").name(:settings)
      end
    end
    
    # If we're in standalone mode, we want to expose the public routes 
    # automatically.
    if Gluttonberg.standalone?
      Merb::BootLoader.after_app_loads do
        Merb::Router.append { gluttonberg_pages("public") }
      end
    end
  end
  
  Gluttonberg.push_path(:models, Gluttonberg.root / "app" / "models")
  unless Merb.environment == 'test'
    Gluttonberg.push_path(:observers, Gluttonberg.root / "app" / "observers")
  end
  
  # This allows users to publish the path to the public pages
  Merb::Router.extensions do
    def gluttonberg_pages(prefix = nil)
      path = prefix ? "/#{prefix}(/:full_path)" : "(/:full_path)"
      match(path, :full_path => /\S+/).to(:controller => "gluttonberg/content/public", :action => "show").
        name(:gluttonberg_public_page)
    end
  end
  
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
  require "gluttonberg/content"
  require "gluttonberg/library"
  require "gluttonberg/admin_controller"
  require "gluttonberg/public_controller"
  require "gluttonberg/core_ext"
  
end