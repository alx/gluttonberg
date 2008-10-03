content = Pathname(__FILE__).dirname.expand_path

require content / "content" / "block"
require content / "content" / "localization"

module Gluttonberg
  module Content
    @@content_associations  = {}
    
    # This is called after the application loads so that we can define any
    # extra associations or do house-keeping once everything is required and
    # running
    def self.setup
      Merb.logger.info("Setting up content classes and assocations")
      [Page, TemplateSection].each do |klass|
        klass.class_eval do
          Gluttonberg::Content.content_associations.each { |name, klass| has n, name, :class_name => klass }
        end
      end
    end
    
    # Returns an array of content associations as symbols
    def self.content_associations
      @@content_associations
    end
    
    def self.register_as_content(klass)
      name = Extlib::Inflection.underscore(klass.name.gsub("::", "").pluralize).to_sym
      @@content_associations[name] = klass
    end
  end
end