module Gluttonberg
  module AdminController
    def self.included(klass)
      klass.class_eval do
        self._template_roots << [Gluttonberg.root / "app" / "views", :_template_location]
        layout("gluttonberg")
        before :ensure_authenticated
      end
    end
    
    def display_delete_confirmation(opts)
      @options = opts
      @options[:title]    ||= "Delete Record?"
      @options[:message]  ||= "If you delete this record, it will be gone permanently. There is no undo."
      render :template => "shared/delete", :layout => false
    end
    
    # Returns an array containing the current page, total page count and 
    # the results
    class Paginator
      attr_reader :current, :total
      def initialize(current, total)
        @current  = current
        @total    = total
      end
      
      def previous?
        @current > 1
      end
      
      def next?
        @current < @total
      end
      
      def previous
        @current - 1
      end
      
      def next
        @current + 1
      end
    end
    
    def paginate(model, opts = {})
      if params[:page]
        page = params[:page].to_i 
        opts[:page] = page
      else
        page = 1
      end
      results = model.send(:paginated, opts)
      [Paginator.new(page, results[0]), results[1]]
    end
  end
end