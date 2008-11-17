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
      Merb::GlobalHelpers.send(:include, Gluttonberg::Helpers)
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
      # Login/Logout
      scope.match("/login", :method => :get ).to(:controller => "/exceptions", :action => "unauthenticated").name(:login)
      scope.match("/login", :method => :put ).to(:controller => "sessions", :action => "update").name(:perform_login)
      scope.match("/logout").to(:controller => "sessions", :action => "destroy").name(:logout)
      
      # The admin dashboard
      scope.match("/").to(:controller => "main").name(:admin_root)
      
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
            as.match("/browse/:category(.:format)", :category => /[a-zA-Z]/).to(:action => "category").name(:asset_category)
          end
          a.resources(:assets, :controller => "library/assets")
          a.resources(:collections, :controller => "library/collections")
        end
      
        # Settings
        s.match("/settings").to(:controller => "settings/main").name(:settings)
        s.match("/settings") do |se|
          se.resources(:locales, :controller => "settings/locales")
          se.resources(:dialects, :controller => "settings/dialects")
          se.resources(:users, :controller => "settings/users")
        end
        
        s.gluttonberg_pages if standalone?
      end
    end
    
   # Bunch of methods related to the configuration
    def self.localized?
      config[:localize] && !config[:translate]
    end
    
    def self.translated?
      config[:translate] && ! config[:localize]
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
        path << "/:locale/:dialect"
      elsif Gluttonberg.translated?
        path << "/:dialect"
      end
      # Add the matcher for the full path.
      match(path << "(/:full_path)", :full_path => /\S+/).
        to(:controller => "/gluttonberg/content/public", :action => "show").name(:public_page)
      
      # TODO: look at matching a root, which people might hit without 
      # selecting a locale or dialect
    end
  end
  
  # Default directory layout
  Gluttonberg.setup_default_structure!
  
  # Third party dependencies
  dependency 'merb-assets',     merb_version
  dependency 'merb-helpers',    merb_version
  dependency 'merb_datamapper', merb_version
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

  # Various mixins and classes
  require "gluttonberg/content"
  require "gluttonberg/library"
  require "gluttonberg/admin_controller"
  require "gluttonberg/public_controller"
  require "gluttonberg/core_ext"
  require "gluttonberg/templates"
  require "gluttonberg/components"
  require "gluttonberg/helpers"
  
end