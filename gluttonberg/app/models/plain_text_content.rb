module Gluttonberg
  class PlainTextContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
            
    is_localized do
      property :text, String
    end
  end
end