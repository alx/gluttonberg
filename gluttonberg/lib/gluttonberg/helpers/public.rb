module Gluttonberg
  module Helpers
    module Public
      # A simple helper which loops through a heirarchy of pages and produces a
      # set of nested lists with links to each page.
      def navigation_tree(pages, opts = {})
        content = ""
        pages.each do |page|
          li_opts = {}
          li_opts[:class] = "current" if page == @page
          li_content = tag(:a, page.nav_label, :href => page_url(page))
          children = page.children_with_localization(:dialect => params[:dialect], :locale => params[:locale])
          li_content << navigation_tree(children) unless children.empty?
          content << "\n\t#{tag(:li, li_content, li_opts)}"
        end
        tag(:ul, "#{content}\n", opts)
      end

      # Returns the URL with any locale/dialect prefix it needs
      def page_url(path_or_page)
        path = path_or_page.is_a?(String) ? path_or_page : path_or_page.path
        ::Gluttonberg::Router.localized_url(path, params)
      end
    end
  end
end