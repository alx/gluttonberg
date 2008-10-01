module Gluttonberg
  class Locale
    include DataMapper::Resource

    property :id,       Integer,  :serial   => true, :key => true
    property :name,     String,   :length   => 1..70
    property :default,  Boolean,  :default  => false

    belongs_to  :fallback_locale,     :class_name => "Gluttonberg::Locale"
    has n,      :page_localizations,  :class_name => "Gluttonberg::PageLocalization"
    has n,      :dialects,            :through => Resource

    # This replaces the existing set of associated dialects with a new set based
    # on the array of IDs passed in.
    def dialect_ids=(new_ids)
      # I'm not quite sure why we need to clear out this association in order to 
      # get the dialects to update properly. But, whatevs.
      self.dialect_locales = []
      self.dialects = Dialect.all(:id => new_ids)
    end
  end
end
