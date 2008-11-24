content = Pathname(__FILE__).dirname.expand_path

require content / "content" / "block"
require content / "content" / "localization"
require content / "content" / "textilized"

module Gluttonberg
  module Content
    @@content_associations = nil
    @@non_localized_associations = nil
    @@content_classes = []
    @@localizations = {}
    @@localization_associations = nil
    @@localization_classes = nil
    
    # This is called after the application loads so that we can define any
    # extra associations or do house-keeping once everything is required and
    # running
    def self.setup
      Merb.logger.info("Setting up content classes and assocations")
      [Page, PageSection].each do |klass|
        klass.class_eval do
          Gluttonberg::Content.content_classes.each do |klass| 
            has n, klass.association_name, :class_name => klass.name 
          end
        end
      end
      # Create associations between content localizations and PageLocalization
      PageLocalization.class_eval do
        Gluttonberg::Content.localizations.each do |assoc, klass|
          has n, assoc, :class_name => klass
        end
      end
      # Store the names of the associations in their own array for convenience
      @@localization_associations = @@localizations.keys
      @@localization_classes = @@localizations.values
      @@content_associations = content_classes.collect { |k| k.association_name }
    end
    
    def self.register_as_content(klass)
      @@content_classes << klass unless @@content_classes.include? klass
    end
    
    def self.content_classes
      @@content_classes
    end
    
    def self.non_localized_associations
      @@non_localized_associations ||= begin
        non_localized = @@content_classes.select {|c| !c.localized? }
        non_localized.collect {|c| c.association_name }
      end
    end
    
    def self.content_associations
      @@content_associations
    end
    
    def self.register_localization(assoc_name, klass)
      @@localizations[assoc_name] = klass
    end
    
    def self.localizations
      @@localizations
    end
    
    def self.localization_associations
      @@localization_associations
    end
  end
end