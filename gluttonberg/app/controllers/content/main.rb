module Gluttonberg
  module Content
    class Main < Gluttonberg::Application
      include Gluttonberg::AdminController

      def index
        render
      end
    end
  end
end