module Gluttonberg
  class PageLocalization
    include DataMapper::Resource

    property :id,           Serial
    property :name,         String,   :length => 150
    property :slug,         String,   :length => 0..50
    property :path,         String,   :length => 255, :writer => :private
    property :created_at,   Time
    property :updated_at,   Time

    belongs_to :page
    belongs_to :dialect
    belongs_to :locale

    after :save, :update_content_localizations

    attr_accessor :paths_need_recaching, :content_needs_saving

    # Write an explicit setter for the slug so we can check it’s not a blank 
    # value. This stops it being overwritten with an empty string.
    def slug=(new_slug)
      attribute_set(:slug, new_slug) unless new_slug.blank?
    end

    # Returns an array of content localizations
    def contents
      @contents ||= begin
        Gluttonberg::Content.localization_associations.inject([]) do |memo, assoc|
          memo += send(assoc).all
        end
      end
    end
    
    # Updates each localized content record and checks their validity
    def contents=(params)
      self.content_needs_saving = true
      contents.each do |content|
        update = params[content.association_name][content.id.to_s]
        content.attributes = update if update
      end
      #all_valid?
    end

    def paths_need_recaching?
      @paths_need_recaching
    end

    def name_and_code
      "#{name} (#{locale.name}/#{dialect.code})"
    end
    
    private
    
    def update_content_localizations
      contents.each { |c| c.save } if self.content_needs_saving
    end
  end
end