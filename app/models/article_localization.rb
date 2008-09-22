class ArticleLocalization
  include DataMapper::Resource
  
  property :id,           Serial
  property :title,        String,   :length => 1..255
  property :body,         Text
  property :created_at,   Time
  property :updated_at,   Time
  
  belongs_to :article
  belongs_to :localization, :class_name => "PageLocalization"
end