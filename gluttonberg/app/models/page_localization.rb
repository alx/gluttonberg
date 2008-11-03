module Gluttonberg
  class PageLocalization
    include DataMapper::Resource

    property :id,           Integer,  :serial => true,    :key => true
    property :name,         String,   :length => 1..150
    property :slug,         String,   :length => 0..50
    property :path,         String,   :length => 1..255,  :nullable => false, :writer => :private
    property :created_at,   Time
    property :updated_at,   Time

    belongs_to :page
    belongs_to :dialect
    belongs_to :locale

    attr_accessor :paths_need_recaching

    # Returns an array of content localizations
    def contents
      @contents ||= begin
        Gluttonberg::Content.localization_associations.inject([]) do |memo, assoc|
          memo += send(assoc).all
        end
      end
    end

    def paths_need_recaching?
      @paths_need_recaching
    end

    def name_and_code
      "#{name} (#{locale.name}/#{dialect.code})"
    end
  end
end