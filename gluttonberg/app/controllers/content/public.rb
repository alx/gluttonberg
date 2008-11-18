module Gluttonberg
  module Content
    class Public < Gluttonberg::Application
      include Gluttonberg::PublicController
      
      #before :set_localization_and_path, :only => :show
      
      def show
        @pages = Page.all_with_localization(:parent_id => nil, :dialect => params[:dialect], :locale => params[:locale])
        @page = params[:page]
        templates = @page.template_paths(:dialect => params[:dialect], :locale => params[:locale])
        render(:template => "pages/" + templates[:page], :layout => "#{templates[:layout]}.#{content_type}")
      end
    end
  end
end