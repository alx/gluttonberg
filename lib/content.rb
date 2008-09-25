content = Pathname(__FILE__).dirname.expand_path

require content / "content" / "block"
require content / "content" / "localization"

module Glutton
  module Content
    @@content_associations  = []
    @@content_classes       = []
    
    # This is called after the application loads so that we can define any
    # extra associations or do house-keeping once everything is required and
    # running
    def self.setup
      Merb.logger.info("Setting up content classes and assocations")
      [Page, TemplateSection].each do |klass|
        klass.class_eval do
          Glutton::Content.content_associations.each { |assoc| has n, assoc }
        end
      end
    end
    
    # Returns an array of classes that have been registered as content blocks
    def self.content_classes
      @@content_classes
    end
    
    # Returns an array of content associations as symbols
    def self.content_associations
      @@content_associations
    end
    
    def self.register_as_content(klass)
      @@content_classes << klass
      name = Extlib::Inflection.underscore(klass.name.pluralize).to_sym
      @@content_associations << name
    end
  end
end

# Run setup after the app loads
Merb::BootLoader.after_app_loads { Glutton::Content.setup }