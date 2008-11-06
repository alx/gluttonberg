module Merb
  module Gluttonberg
    module ApplicationHelper
      def navigation_tree(pages, opts = {})
        content = ""
        pages.each do |page|
          li_opts = {}
          li_opts[:class] = "current" if page == @page
          content << "\n\t#{tag(:li, tag(:a, page.title, :href => page_url(page)), li_opts)}"
          children = page.children_with_localization(:dialect => dialect, :locale => locale)
          content << navigation_tree(children) unless children.empty?
        end
        tag(:ul, "#{content}\n", opts)
      end
      
      # Returns the URL with any locale/dialect prefix it needs
      def page_url(path_or_page)
        path = path_or_page.is_a?(String) ? path_or_page : path_or_page.path
        opts = {:full_path => path}
        if ::Gluttonberg.localized?
          opts.merge!({:locale => locale.slug, :dialect => dialect.code})
        elsif ::Gluttonberg.translated?
          opts.merge!({:dialect => dialect.code})
        end
        slice_url(:public_page, opts)
      end
      
      # Writes out a row for each page and then for each page's children, 
      # iterating down through the heirarchy.
      def page_table_rows(pages, output = "", inset = 0)
        pages.each do |page|
          output << partial("content/pages/row", :page => page, :inset => inset)
          page_table_rows(page.children, output, inset + 1)
        end
        
        output
      end
      
      # Takes text and url and checks to see if the path specified matches the 
      # current url. This is so we can add a highlight.
      def main_nav_entry(text, mod, url, opts = {})
        li_opts = if params[:controller].match(%r{^gluttonberg/#{mod}/})
          {:class => "current"}
        else
          {}
        end
        tag("li", link_to(text, url, opts), li_opts)
      end
      
      # Finds the matching content block and determines the helper it needs
      # to execute to actually write the contents to page.
      # TODO: if there is no way to to render the content, freak out and raise
      # an error
      def render_content_for(section_name)
        # At present this generates a bunch of queries. Eventually we should 
        # look at caching section names to save some DB hits.
        content = @page.localized_contents.pluck {|c| c.section.name == section_name}
        render_method = :"render_#{content.content_type}"
        if respond_to? render_method
          send(:"render_#{content.content_type}", content)
        elsif content.respond_to? :text
          content.text
        else
          # raise Gluttonberg::ContentRenderError, "Don't know how to render this content"
        end
      end
      
      def render_rich_text_content(content)
        content.current_localization.formatted_text
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
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def image_path(*segments)
        public_path_for(:image, *segments)
      end
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def javascript_path(*segments)
        public_path_for(:javascript, *segments)
      end
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def stylesheet_path(*segments)
        public_path_for(:stylesheet, *segments)
      end
      
      # Construct a path relative to the public directory
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def public_path_for(type, *segments)
        ::Gluttonberg.public_path_for(type, *segments)
      end
      
      # Construct an app-level path.
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path within the host application, with added segments.
      def app_path_for(type, *segments)
        ::Gluttonberg.app_path_for(type, *segments)
      end
      
      # Construct a slice-level path.
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path within the slice source (Gem), with added segments.
      def slice_path_for(type, *segments)
        ::Gluttonberg.slice_path_for(type, *segments)
      end
      
    end
  end
end