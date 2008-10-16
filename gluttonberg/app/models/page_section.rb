module Gluttonberg
  class PageSection
    include DataMapper::Resource

    property :id,     Serial
    property :label,  String, :length => 100, :nullable => false
    property :name,   String, :length => 100, :nullable => false
    property :type,   String, :length => 50,  :nullable => false

    belongs_to :page_type
  end
end
