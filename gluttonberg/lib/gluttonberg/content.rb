content = Pathname(__FILE__).dirname.expand_path

require content / "content" / "block"
require content / "content" / "localization"

module Gluttonberg
  module Content
    @@content_classes = []
    
    # This is called after the application loads so that we can define any
    # extra associations or do house-keeping once everything is required and
    # running
    def self.setup
      Merb.logger.info("Setting up content classes and assocations")
      [Page, PageSection].each do |klass|
        klass.class_eval do
          Gluttonberg::Content.types.each do |klass| 
            has n, klass.association_name, :class_name => klass.name 
          end
        end
      end
    end
    
    def self.register_as_content(klass)
      @@content_classes << klass unless @@content_classes.include? klass
    end
    
    def self.types
      @@content_classes
    end
  end
end