module Gluttonberg
  module Settings
    class Main < Gluttonberg::Application
      include Gluttonberg::AdminController

      def index
        render
      end
    end
  end
end