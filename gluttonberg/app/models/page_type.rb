module Gluttonberg
  class PageType
    include DataMapper::Resource

    property :id,       Serial
    property :name,     String, :length => 100, :nullable => false
    property :filename, String, :length => 100, :nullable => false
    
    has n, :pages
    has n, :sections, :class_name => "Gluttonberg::PageSection"
  end
end
