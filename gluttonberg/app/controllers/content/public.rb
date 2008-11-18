module Gluttonberg
  module Content
    class Public < Gluttonberg::Application
      include Gluttonberg::PublicController
      
      def show
        render(:template => page_template, :layout => page_layout)
      end
    end
  end
end