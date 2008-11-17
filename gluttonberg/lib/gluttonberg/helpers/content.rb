module Gluttonberg
  module Helpers
    module Content
      # Finds the matching content block and determines the helper it needs
      # to execute to actually write the contents to page.
      # TODO: if there is no way to to render the content, freak out and raise
      # an error
      def render_content_for(section_name, opts = {})
        # At present this generates a bunch of queries. Eventually we should 
        # look at caching section names to save some DB hits.
        content = content_for(section_name)
        render_method = :"render_#{content.content_type}"
        if respond_to? render_method
          send(:"render_#{content.content_type}", content, opts)
        elsif content.respond_to? :text
          content.text
        else
          # raise Gluttonberg::ContentRenderError, "Don't know how to render this content"
        end
      end

      # Returns the content record for the specified section. It will include
      # the relevant localized version based the current locale/dialect
      def content_for(section_name, opts = nil)
        @page.localized_contents.pluck {|c| c.section.name == section_name}
      end

      def render_rich_text_content(content, opts = nil)
        content.current_localization.formatted_text
      end

      def render_image_content(content, opts = {})
        if content.asset
          image_tag(content.asset.url, opts.merge!(:alt => content.asset.name))
        else
          tag(:p, "Image missing")
        end
      end

      def render_plain_text_content(content, opts = nil)
        content.current_localization.text
      end

      # Looks for a matching partial in the templates directory. Failing that, 
      # it falls back to Gluttonberg's view dir — views/content/editors
      def content_editor(content_class)
        locals  = {:content => content_class}
        type    = content_class.content_type
        glob    = ::Gluttonberg::Templates.path_for("editors") / "_#{type}.#{content_type}.*"
        unless Dir[glob].empty?
          partial(::Gluttonberg::Templates.path_for("editors") / type, locals)
        else
          partial("content/editors/#{type}", locals)
        end
      end
    end
  end
end