module Gluttonberg
  class PlainTextContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
            
    is_localized do
      property :text, String, :length => 255
    end
  end
end