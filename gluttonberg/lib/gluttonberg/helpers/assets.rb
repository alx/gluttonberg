module Gluttonberg
  module Helpers
    module Assets
      def gluttonberg_image_path(*segments)
        gluttonberg_public_path_for(:image, *segments)
      end

      def gluttonberg_javascript_path(*segments)
        gluttonberg_public_path_for(:javascript, *segments)
      end

      def gluttonberg_stylesheet_path(*segments)
        gluttonberg_public_path_for(:stylesheet, *segments)
      end

      def gluttonberg_public_path_for(type, *segments)
        ::Gluttonberg.public_path_for(type, *segments)
      end
    end
  end
end