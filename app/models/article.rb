class Article
  include DataMapper::Resource
  
  property :id,           Serial
  property :section_name, String,   :length => 1..255
  property :orphaned,     Boolean,  :default => false
  property :created_at,   Time
  property :updated_at,   Time
  
  belongs_to :page
  has n, :localizations, :class_name => "ArticleLocalization"
end