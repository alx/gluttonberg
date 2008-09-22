Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # Administration paths
  r.match("/admin").to(:namespace => "admin") do |a|
    a.match("/content") do |c|
      c.resources(:dialects)
      c.resources(:locales)
      c.resources(:templates) do |t|
        t.resources(:sections, :controller => "template_sections")
      end
      c.resources(:pages) do |p|
        p.resources(:localizations, :controller => "page_localizations")
        p.resources(:articles)
      end
    end
    
    a.match("/content").to(:controller => "content").name(:admin_content)
    
    a.resources(:assets)
    
    a.resources(:users)
    
    a.match("/settings").to(:controller => "settings") do |s|
      s.match(:method => "get").to(:action => "index").name(:admin_settings)
      s.match(:method => "put").to(:action => "update")
    end
  end
  
  r.match(/(.*)/).to(:controller => "public/pages", :action => "show", :path => "[1]")
end