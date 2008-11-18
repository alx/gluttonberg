module Gluttonberg
  module PublicController
    def self.included(klass)
      klass.class_eval do
        attr_accessor :page, :dialect, :locale, :path, :page_template, :page_layout
        self._template_roots << [Gluttonberg::Templates.root, :_template_location]
        before :store_models_and_templates
        before :find_pages
      end
    end
    
    private
    
    def find_pages
      @pages = Page.all_with_localization(:parent_id => nil, :dialect => params[:dialect], :locale => params[:locale])
    end
    
    def store_models_and_templates
      @dialect  = params[:dialect]
      @locale   = params[:locale]
      @page     = params[:page]
      # Store the templates
      templates       = @page.template_paths(:dialect => params[:dialect], :locale => params[:locale])
      @page_template  = "pages/" + templates[:page]
      @page_layout    = "#{templates[:layout]}.#{content_type}"
    end
  end
end