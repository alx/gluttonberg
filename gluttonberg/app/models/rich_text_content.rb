module Gluttonberg
  class RichTextContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
    
    is_content :label => "Rich Text", :association_name => :rich_texts
    
    is_localized do
      property :text, Text
    end
  end
end