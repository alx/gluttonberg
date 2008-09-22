class TemplateSection
  include DataMapper::Resource

  property :id,     Serial
  property :label,  String, :length => 100, :nullable => false
  property :name,   String, :length => 50,  :nullable => false
  # TODO: Eventually this will pull in registered content classes
  property :type,   Enum[:article], :default => :article
  
  belongs_to :template
end
