module Glutton
  module Content
    def self.included(klass)
      klass.class_eval do
        property :section_name, String,   :length => 1..255
        property :orphaned,     Boolean,  :default => false
        property :created_at,   Time
        property :updated_at,   Time
        
        belongs_to :page
        has n, :localizations, :class_name => "#{self.class.to_s}Localization", :dependent => :destroy
      end
    end
  end
end

class Article
  include DataMapper::Resource
  #include Glutton::Content
  
  property :id,           Serial
  property :section_name, String,   :length => 1..255
  property :orphaned,     Boolean,  :default => false
  property :created_at,   Time
  property :updated_at,   Time
  
  belongs_to :page
  has n, :localizations, :class_name => "ArticleLocalization"
end