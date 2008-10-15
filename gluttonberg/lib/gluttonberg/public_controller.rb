module Gluttonberg
  module PublicController
    def self.included(klass)
      klass.send(:attr_accessor, :dialect, :locale, :path)
    end
    
    private

    def set_localization_and_path
      if Gluttonberg.localized? || Gluttonberg.translated?
        # Get the dialect
        # TODO: Have this only grab the active dialects
        # TODO: fall back to the accept header i.e. request.env["HTTP_ACCEPT_LANGUAGE"]
        @dialect = cascade_to_dialect(Dialect.all, params[:dialect])
        # See if we need the locale as well
        if Gluttonberg.localized?
          @locale = Locale.first(:slug => params[:locale]) || Locale.first(:default => true)
        end
      end
      
      @path = params[:full_path]
    end

    def cascade_to_dialect(dialects, requested_dialect)
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
  end
end