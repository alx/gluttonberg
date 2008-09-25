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
  
  before :valid?, :cache_path
  
  def cache_path
    attribute_set(:path, "/#{slug}")
  end
  
  def name_and_code
    "#{name} (#{locale.name}/#{dialect.code})"
  end

  def cache_path!(path_prefix)
    update_attributes(:path => "#{path_prefix}/#{slug}")
    # See if we have any children to update
    decendants = page.children.localizations.all(:locale_id => locale_id, :dialect_id => dialect_id)
    decendants.each { |l| l.cache_path!(path) } unless decendants.empty?
  end
end