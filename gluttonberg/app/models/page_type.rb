module Gluttonberg
  class PageType
    include DataMapper::Resource
    include Gluttonberg::TemplateMixin

    property :id,       Serial
    property :name,     String, :length => 100, :nullable => false
    property :filename, String, :length => 100, :nullable => false
    
    has n, :pages
    has n, :sections, :class_name => "Gluttonberg::PageSection"
    
    private 
    
    def template_type
      :pages
    end
  end
end
