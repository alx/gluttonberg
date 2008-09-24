Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # Administration paths
  match("/admin").to(:namespace => "admin") do
    match("/content") do
      resources(:dialects)
      resources(:locales)
      resources(:templates) do
        resources(:sections, :controller => "template_sections")
      end
      resources(:pages) do
        resources(:localizations, :controller => "page_localizations")
        resources(:articles)
      end
    end
    
    match("/content").to(:controller => "content").name(:content)
    resources(:assets)
    resources(:users)
    
    match("/settings").to(:controller => "settings") do |s|
      match(:method => "get").to(:action => "index").name(:settings)
      match(:method => "put").to(:action => "update")
    end
  end
  
  match(/(.*)/).to(:controller => "public/pages", :action => "show", :path => "[1]")
end