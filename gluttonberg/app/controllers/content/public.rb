module Gluttonberg
  module Content
    class Public < Gluttonberg::Application
      include Gluttonberg::PublicController
      
      before :set_localization_and_path, :only => :show
      
      def show
        begin
          @page = Page.first_with_localization(:path => path, :dialect_id => dialect.id, :locale_id => locale.id)
        rescue DataMapper::ObjectNotFoundError
          raise NotFound
        end
        render(:template => "public/pages/#{@page.template_name}", :layout => @page.layout_name)
      end
    end
  end
end