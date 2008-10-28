module Gluttonberg
  module Content
    # This module can be mixed into a class to make it behave like a content 
    # block. A content block is a class that can be associated with a section
    # on a page.
    module Block
      def self.included(klass)
        klass.class_eval do
          extend Block::ClassMethods
          
          class << self; attr_accessor :localized, :label, :association_name end
          @localized = false
          
          property :orphaned,     ::DataMapper::Types::Boolean, :default => false
          property :created_at,   Time
          property :updated_at,   Time 
          
          belongs_to :page
          belongs_to :section, :class_name => "PageSection"
        end
        
        # This registers this class so that the page can later query which 
        # classes it needs to be aware of.
        Gluttonberg::Content.register_as_content(klass)
      end
    
      module ClassMethods
        
        # Is used to set defaults for this class
        def is_content(opts = {})
          self.label = opts[:label] || name
          self.association_name = if opts[:association_name]
            opts[:association_name]
          else
            Extlib::Inflection.underscore(name.gsub("::", "_").pluralize).to_sym
          end
        end
        
        def is_localized(&blk)
          self.localized = true
        
          # Generate the localization model
          storage_name = Extlib::Inflection.tableize(self.name + "Localization")
          self.const_set("Localization", DataMapper::Model.new(storage_name))
        
          # Mix in our base set of properties and methods
          self::Localization.send(:include, Gluttonberg::Content::Localization)
          # Generate additional properties from the block passed in
          self::Localization.class_eval(&blk)
        
          # Set up filters on the class to make sure the localization gets migrated
          self.after_class_method :auto_migrate! do
            self::Localization.auto_migrate!
          end
          self.after_class_method :auto_upgrade! do
            self::Localization.auto_upgrade!
          end
        
          # Set up the associations
          has n, :localizations
          self::Localization.belongs_to(:parent, :class_name => self.name)
        end
        
        # Does this class have an associated localization class.
        def localized?
          self.localized
        end
      end
    end
  end
end