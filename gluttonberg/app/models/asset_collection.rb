module Gluttonberg
  class AssetCollection
    include DataMapper::Resource

    property :id,   Serial
    property :name, String

    has n, :assets, :through => Resource, :class_name => "Gluttonberg::Asset"
  end
end