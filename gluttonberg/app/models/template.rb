module Gluttonberg
  class Template
    include DataMapper::Resource

    property :id,         Serial
    property :name,       String, :length => 100,       :nullable => false
    property :file_name,  String, :length => 100,       :nullable => false
    property :type,       Enum[:view, :layout],         :default  => :view
    property :format,     Enum[:html, :json, :xml],     :default  => :html
    property :language,   Enum[:haml, :erb, :builder],  :default  => :haml
    
    # Type can go. Instead we'll have a layout model which will handle the
    # layout templates only
    
    # format can become :formats instead. Rather than an enum we can use a 
    # flag indicating which formats are available. The template renderer 
    # doesn't care about this stuff, but it's useful in the back end
    
    # Language is irrellevant. The template render doesn't care, so there is 
    # no reason why we should.
    
    # Need to handle file uploads and remove them from the disk if this record
    # gets squashed.
    
    # Template files. We may have a different template for each locale. So 
    # we might specify a page type for a page and then upload templates
    # for each locale, which would then be stored on disk using a particular
    # naming convention
    #
    #   default.en-gb.html.haml
    #
    # Using roughly the same conventions as Merb. This could also apply to 
    # different formats, so you might also have the following defined
    #
    #   default.en-gb.xml.haml
    # or
    #   default.en-gb.yml.erb

    has n, :pages
    has n, :sections, :class_name => "TemplateSection"

    # Returns all templates with the view type
    def self.views
      all(:type => :view, :order => [:name.asc])
    end

    # Returns all templates with the layout type
    def self.layouts
      all(:type => :layout, :order => [:name.asc])
    end
  end
end