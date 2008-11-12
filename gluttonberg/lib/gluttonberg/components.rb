module Gluttonberg
  module Components
    @@components  = {}
    @@routes      = {}
    @@nav_entries = nil
    @@registered  = nil
    Component     = Struct.new(:name, :label)
    
    # Components.register(:forum, :label => "Forum", :admin_url => url) do |scope|
    #   scope.resources(:posts)
    #   scope.resources(:threads)
    # end
    def self.register(name, opts = {}, &routes)
      @@components[name] = opts
      @@routes[name] = routes if block_given?
    end
    
    def self.registered
      @@registered ||= @@components.collect {|k, v| Component.new(k.to_s, v[:label])}
    end
    
    def self.routes
      @@routes
    end
    
    def self.nav_entries
      @@nav_entries ||= @@components.collect do |k, v| 
        url = if v[:admin_url]
          if v[:admin_url].is_a? Symbol
            Merb::Router.url(v[:admin_url])
          else
            v[:admin_url]
          end
        end        
        [v[:label], k, url]
      end
    end
  end
end
