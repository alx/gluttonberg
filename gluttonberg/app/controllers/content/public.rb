module Gluttonberg
  module Content
    class Public < Gluttonberg::Application
      include Gluttonberg::PublicController
      
      self._template_roots = [[Templates.root, :_template_location]]
      
      before :set_localization_and_path, :only => :show
      
      def show
        begin
          @page = Page.first_with_localization(:path => path, :dialect_id => dialect.id, :locale_id => locale.id)
        rescue DataMapper::ObjectNotFoundError
          raise NotFound
        end
        templates = @page.template_paths(:dialect => dialect, :locale => locale)
        render(:template => "pages/" + templates[:page], :layout => "#{templates[:layout]}.#{content_type}")
      end
    end
  end
end