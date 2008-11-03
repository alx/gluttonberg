module Gluttonberg
  class RichTextContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
    
    is_content :label => "Rich Text", :association_name => :rich_texts
    
    is_localized :association_name => :rich_text_localizations do
      property :text, Text
    end
  end
end