module Gluttonberg
  module PublicController
    def self.included(klass)
      klass.send(:attr_accessor, :dialect, :locale, :path)
    end
    
    private

    def set_localization_and_path
      # Get the dialect
      dialects = Dialect.all
      accept_dialect = params[:dialect] || request.env["HTTP_ACCEPT_LANGUAGE"]
      @dialect = cascade_to_dialect(dialects, accept_dialect)
      # Get the locale
      @locale = Locale.first(:name => params[:locale]) || Locale.first(:default => true)
      
      # We should examine the path to see if a dialect and/or locale is specified.
      # How this would be encoded into the path would depend on the options
      # specified in the settings. For example the locale may be set via a sub-domain
      # and the language set via the path in the URL.
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