module Gluttonberg
  module Router
    # Set up the many and various routes for Gluttonberg
    def self.setup(scope)
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
        
        s.gluttonberg_public_routes if Gluttonberg.standalone?
      end
    end
    
    # TODO: look at matching a root, which people might hit without 
    # selecting a locale or dialect
    PUBLIC_DEFER_PROC = lambda do |request, params|
      additional_params, conditions = Gluttonberg::Router.localization_details(params)
      page = Gluttonberg::Page.first_with_localization(conditions.merge(:path => params[:full_path]))
      if page
        case page.behaviour
          when :component
            Gluttonberg::Router.rewrite(localization, request, additional_params)
          when :passthrough
            page.passthrough_target.load_localization(
              :locale   => additional_params[:locale].id,
              :dialect  => additional_params[:dialect].id
            )
            redirect(Gluttonberg::Router.localized_url(page.current_localization.path))
          else
            {:controller => params[:controller], :action => params[:action], :page => page}.merge!(additional_params)
        end
      else
        # TODO: The string concatenation here is Sqlite specific, we need to 
        # handle it differently per adapter.
        component_conditions = conditions.merge(
          :behaviour  => :component,
          :conditions => ["? LIKE (path || '%')", params[:full_path]], 
          :order      => [:path.asc]
        )
        page = Gluttonberg::Page.first_with_localization(component_conditions)
        if page
          Gluttonberg::Router.rewrite(localization, request, additional_params)
        else
          raise Merb::ControllerExceptions::NotFound
        end
      end
    end
    
    def self.localization_details(params)
      # check to see if we're localized, translated etc, then build the 
      # conditions and the additional params with the locale/dialect stuffed
      # into them. Also should include the full_path
      additional_params = {}
      conditions = {}
      if Gluttonberg.localized?
        locale = Gluttonberg::Locale.first(:slug => params[:locale])
        raise Merb::ControllerExceptions::NotFound unless locale
        additional_params[:locale] = locale
        conditions[:locale_id] = locale.id
      end
      if Gluttonberg.translated?
        dialect = cascade_to_dialect(
          Gluttonberg::Dialect.all(:conditions => ["? LIKE code || '%'", params[:dialect]]),
          params[:dialect]
        )
        raise Merb::ControllerExceptions::NotFound unless dialect
        additional_params[:dialect] = dialect
        conditions[:dialect_id] = dialect.id
      end
      additional_params[:original_path] = params[:full_path]
      # If it's all good just return them both
      [additional_params, conditions]
    end
    
    def self.cascade_to_dialect(dialects, requested_dialect)
      # If the dialects are empty, just return the default straight away.
      #
      # If we have dialects in our DB, let's try to find a match. If we don't
      # have any matches, lets reduce the request lang and recurse until we find 
      # a match or need to return the default.
      if dialects.nil?
        dialects.first(:default => true)
      else
        match = dialects.pluck {|d| d.code == requested_dialect}
        if match
          match
        else
          index = requested_dialect.rindex("-")
          if index
            cascade_to_dialect(dialects, requested_dialect[0, index])
          else
            dialects.first(:default => true)
          end
        end
      end
    end
    
    def self.rewrite(page, request, additional_params)
      additional_params[:page] = page
      request.env["REQUEST_PATH"].gsub!(page.current_localization.path, "public/#{page.component}")
      new_params = Merb::Router.match(request)[1]
      new_params.merge(additional_params)
    end
    
    def self.localized_url(path, params)
      opts = {:full_path => path}
      if ::Gluttonberg.localized_and_translated?
        opts.merge!({:locale => params[:locale].slug, :dialect => params[:dialect].code})
      elsif ::Gluttonberg.localized?
        opts.merge!({:locale => params[:locale].slug})
      elsif ::Gluttonberg.translated?
        opts.merge!({:dialect => params[:dialect].code})
      end
      Merb::Router.url((Gluttonberg.standalone? ? :gluttonberg_public_page : :public_page), opts)
    end
    
    Merb::Router.extensions do
      def gluttonberg_public_routes(opts = {})
        Merb.logger.info("Adding Gluttonberg's public routes")
        # See if we need to add the prefix
        path = opts[:prefix] ? "/#{opts[:prefix]}" : ""
        # Check to see if this is localized or translated and if either need to
        # be added as a URL prefix. For now we just assume it's going into the
        # URL.
        if Gluttonberg.localized_and_translated?
          path << "/:locale/:dialect"
        elsif Gluttonberg.localized?
          path << "/:locale"
        elsif Gluttonberg.translated?
          path << "/:dialect"
        end
        controller = Gluttonberg.standalone? ? "content/public" : "gluttonberg/content/public"
        # Set up the defer to block
        match(path << "(/:full_path)", :full_path => /\S+/).defer_to(
          {:controller => controller, :action => "show"},
          &Gluttonberg::Router::PUBLIC_DEFER_PROC).name(:public_page)
      end
    end
  end
end