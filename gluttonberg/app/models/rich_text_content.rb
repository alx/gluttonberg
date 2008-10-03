module Gluttonberg
  class RichTextContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
    
    content_name = "Rich Text"
    
    is_localized do
      property :text, Text
    end
  end
end