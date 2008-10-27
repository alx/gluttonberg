module Gluttonberg
  class Layout
    include DataMapper::Resource
    include Gluttonberg::TemplateMixin

    property :id,       Serial
    property :name,     String, :length => 100, :nullable => false
    property :filename, String, :length => 100, :nullable => false, :unique => true

    has n, :pages
    
    set_template_dir "layout"
  end
end
