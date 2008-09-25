class RichTextContent
  include DataMapper::Resource
  include Glutton::Content::Block
  
  property :id, Serial
    
  is_localized do
    property :text, Text
  end
end