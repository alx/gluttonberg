module Gluttonberg
  class TemplateSection
    include DataMapper::Resource

    property :id,     Serial
    property :label,  String, :length => 100, :nullable => false
    property :name,   String, :length => 50,  :nullable => false
    property :type,   String, :length => 75,  :nullable => false

    belongs_to :template
  end
end