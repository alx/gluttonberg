module Gluttonberg
  class AssetLocalization
    include DataMapper::Resource
    include Library::AttachmentMixin

    property :id,           Serial
    property :created_at,   Time
    property :updated_at,   Time

    belongs_to :asset
    belongs_to :locale
    belongs_to :dialect

    after :save, :update_file_on_disk

    def type
      asset.type
    end
  end
end