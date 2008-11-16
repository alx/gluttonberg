module Gluttonberg
  class Locale
    include DataMapper::Resource

    property :id,       Integer,  :serial   => true, :key => true
    property :name,     String,   :length   => 1..70, :nullable => false
    property :slug,     String,   :length   => 1..70, :nullable => false
    property :default,  Boolean,  :default  => false

    belongs_to  :fallback_locale,     :class_name => "Gluttonberg::Locale"
    has n,      :page_localizations,  :class_name => "Gluttonberg::PageLocalization"
    has n,      :dialects,            :through => Resource, :class_name => "Gluttonberg::Dialect"

    # This replaces the existing set of associated dialects with a new set based
    # on the array of IDs passed in.
    def dialect_ids=(new_ids)
      # This is slightly crude, but lets just delete the join models that we
      # don't need anymore.

      # NOTE: Datamapper will try to insert rows into the join table on a Many to Many
      # even if the relationship is already defined.
      # You need to clear the relationships and reinsert them to prevent composite key
      # violation errors

      #self.gluttonberg_dialect_gluttonberg_locales.all(:dialect_id.not => new_ids).destroy!
      clear_all_dialects
      self.dialects = Dialect.all(:id => new_ids)
    end

    def clear_all_dialects
      self.gluttonberg_dialect_gluttonberg_locales.all.destroy! unless self.new_record?
    end
  end
end
