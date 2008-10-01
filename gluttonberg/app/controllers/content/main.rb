module Gluttonberg
  module Content
    class Main < Application
      include Gluttonberg::AdminController

      def index
        render
      end
    end
  end
end