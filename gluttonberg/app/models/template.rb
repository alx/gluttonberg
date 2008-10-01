module Gluttonberg
  class Template
    include DataMapper::Resource

    property :id,         Serial
    property :name,       String, :length => 100,       :nullable => false
    property :file_name,  String, :length => 100,       :nullable => false
    property :type,       Enum[:view, :layout],         :default  => :view
    property :format,     Enum[:html, :json, :xml],     :default  => :html
    property :language,   Enum[:haml, :erb, :builder],  :default  => :haml

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