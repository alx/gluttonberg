module Gluttonberg
  class Asset
    include DataMapper::Resource
    include Library::AttachmentMixin
    
    property :id,         Serial 
    property :category,   Enum[*Library::CATEGORIES]
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
    before  :valid?,  :set_category_and_type
    
    def localized?
      localized
    end
    
    def full_type
      attribute_get(:type) ? "#{attribute_get(:type)} #{category}" : category
    end
    
    def type
      attribute_get(:type) ? attribute_get(:type) : category
    end
    
    private
    
    def set_category_and_type
      unless file.nil?
        attribute_set(:mime_type, file[:content_type])
        # Determine the category based on the matchers specified in the library
        Library::CATEGORY_PATTERNS.each do |t, m|
          attribute_set(:category, t) if mime_type.match(m)
        end
        # Now slightly more complicated; check the extension, then mime type to
        # try and determine the exact asset type.
        #
        # See if it has an extension
        # If it has, check it against the list inside the patterns
        # If it doesn't, use the regex patterns to examine the mime-type
        # If none match, mark it as generic
        attribute_set(:type, nil)
        match = file[:filename].match(%r{\.([a-zA-Z]{2,6})$})
        if match && match[1]
          Library::TYPE_PATTERNS.each do |type, values|
            attribute_set(:type, type) if values.include?(match[1])
          end
        else
          Library::TYPE_PATTERNS.each do |type, values|
            attribute_set(:type, type) if mime_type.match(values.last)
          end
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
