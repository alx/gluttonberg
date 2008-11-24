module Gluttonberg
  class RichTextContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
            
    is_localized do
      property :text,           Text
      
      before :save, :convert_textile_text_to_html
      
      is_textilized :text
    end
  end
end