module Gluttonberg
  class Asset
    include DataMapper::Resource
    include Library::AttachmentMixin
    
    property :id,         Serial 
    property :type,       Enum[*Library::TYPES]
    property :mime_type,  String
    property :localized,  Boolean, :default => false
    property :created_at, Time
    property :updated_at, Time

    has n, :localizations, :class_name => "Gluttonberg::AssetLocalization"
    has n, :collections, :through => Resource, :class_name => "Gluttonberg::AssetCollection"
    
    # These are for temporarily storing values to be inserted into a 
    # localization. They are only used when the asset is first created or
    # when it's in non-localize-mode.
    attr_accessor :locale_id, :dialect_id
    
    after   :save,    :update_file
    before  :valid?,  :set_type
    
    def localized?
      localized
    end
    
    private
    
    def set_type
      unless file.nil?
        attribute_set(:mime_type, file[:content_type])
        # Determine the type based on the matchers specified in the library
        Library::TYPE_PATTERNS.each do |t, m|
          attribute_set(:type, t) if mime_type.match(m)
        end
      end
    end
    
    def update_file
      if localized? and new_record?
        AssetLocalization.create(
          :asset        => self, 
          :locale_id    => locale_id,
          :dialect_id   => dialect_id,
          :name         => name,
          :description  => description,
          :file         => file
        )
      else
        update_file_on_disk
      end
    end
  end
end
