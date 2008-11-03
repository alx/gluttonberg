if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)

  load_dependency 'merb-slices', "0.9.12"
  Merb::Plugins.add_rakefiles "gluttonberg/tasks/merbtasks", "gluttonberg/tasks/slicetasks", "gluttonberg/tasks/spectasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Default configuration
  Merb::Slices::config[:gluttonberg] = {
    :layout         => :gluttonberg,
    :localize       => true,
    :translate      => false,
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
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
      Content.setup
      Library.setup
      stub_template_dirs
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
          c.resources(:types, :controller => "content/page_types", :name_prefix => "page") do |p|
            p.resources(:sections, :controller => "content/page_sections")
          end
          c.resources(:layouts, :controller => "content/layouts")
        end
        
        # Asset Library
        s.match("/library").to(:controller => "library/main").name(:library)
        s.match("/library") do |a|
          a.match("/assets").to(:controller => "library/assets") do |as|
            as.match("/browser").to(:action => "browser").name(:asset_browser)
            as.match("/:category", :category => /[a-zA-Z]/).to(:action => "category").name(:asset_category)
          end
          a.resources(:assets, :controller => "library/assets")
          a.resources(:collections, :controller => "library/collections")
        end
      
        # Users
        s.match("/users").to(:controller => "users").name(:users)
      
        # Settings
        s.match("/settings").to(:controller => "settings/main").name(:settings)
        s.match("/settings") do |se|
          se.resources(:locales, :controller => "settings/locales")
          se.resources(:dialects, :controller => "settings/dialects")
        end
        
        s.gluttonberg_pages #if standalone?
      end
    end
    
   # Bunch of methods related to the configuration
    def self.localized?
      config[:localize] && !config[:translate]
    end
    
    def self.translated?
      config[:translate] && ! config[:localize]
    end
    
    def self.stub_template_dirs
      unless File.exists?(config[:template_dir])
        FileUtils.mkdir(config[:template_dir])
        %w(layout pages editors).each {|d| FileUtils.mkdir(config[:template_dir] / d)}
      end
    end
    
    def self.templates_dir(type = nil)
      if type.nil?
        config[:template_dir]
      else
        config[:template_dir] / type
      end
    end
  end
  
  Gluttonberg.push_path(:models, Gluttonberg.root / "app" / "models")
  unless Merb.environment == 'test'
    Gluttonberg.push_path(:observers, Gluttonberg.root / "app" / "observers")
  end
  
  # This allows users to publish the path to the public pages
  Merb::Router.extensions do
    def gluttonberg_pages(opts = {})
      Merb.logger.info("Adding Gluttonberg's public routes")
      # See if we need to add the prefix
      path = opts[:prefix] ? "/#{opts[:prefix]}" : ""
      # Check to see if this is localized or translated and if either need to
      # be added as a URL prefix. For now we just assume it's going into the
      # URL.
      if Gluttonberg.localized?
        path << "/:locale/:dialect(/:full_path)"
      elsif Gluttonberg.translated?
        path << "/:dialect(/:full_path)"
      else
        path << "(/:full_path)"
      end
      # Add the matcher for the full path.
      match(path, :full_path => /\S+/).to(:controller => "/gluttonberg/content/public", :action => "show").
        name(:public_page)
      # TODO: look at matching a root, which people might hit without 
      # selecting a locale or dialect
    end
  end
  
  # Default directory layout
  Gluttonberg.setup_default_structure!
  
  # Third party dependencies
  dependency 'merb_datamapper', "0.9.12"
  dependency 'dm-is-tree', "0.9.6"
  dependency 'dm-observer', "0.9.6"
  dependency 'dm-is-list', "0.9.6"
  dependency 'dm-validations', "0.9.6"
  dependency 'dm-timestamps', "0.9.6"
  dependency 'dm-types', "0.9.6"
  dependency 'merb-assets', "0.9.12"
  dependency 'merb-helpers', "0.9.12"

  # Various mixins and classes
  require "gluttonberg/content"
  require "gluttonberg/library"
  require "gluttonberg/admin_controller"
  require "gluttonberg/public_controller"
  require "gluttonberg/core_ext"
  require "gluttonberg/template_mixin"
  
end