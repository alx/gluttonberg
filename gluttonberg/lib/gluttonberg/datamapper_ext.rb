module DataMapper
  module Resource
    module ClassMethods
      def paginated(opts = {})
        # Default options
        page     = opts.delete(:page) || 1
        per_page = opts.delete(:per_page) || 5
        # Find out how many pages there are in total
        total_pages = (count(opts).to_f / per_page).ceil
        # Mix in additional conditions for the actual find call
        opts = {
          :limit => per_page, 
          :offset => (page - 1) * per_page, 
          :order => [:id.desc]
        }.merge!(opts)
        # Return the lot in an array to do as thou wilt
        [total_pages, all(opts)]
      end
    end
  end
end
