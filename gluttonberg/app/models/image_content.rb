module Gluttonberg
  class ImageContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
    
    belongs_to :asset
  end
end