module Gluttonberg
  module Content
    # This module can be mixed into a class to make it behave like a content 
    # block. A content block is a class that can be associated with a section
    # on a page.
    module Block
      def self.included(klass)
        klass.class_eval do
          extend Block::ClassMethods
          include Block::InstanceMethods
          
          class << self; attr_accessor :localized, :label, :content_type, :association_name end
          @localized = false
          
          attr_reader :current_localization
          
          property :orphaned,     ::DataMapper::Types::Boolean, :default => false
          property :created_at,   Time
          property :updated_at,   Time 
          
          belongs_to :page
          belongs_to :section, :class_name => "PageSection"
          
          # Generate the various names to be used in associations
          type = Extlib::Inflection.underscore(Extlib::Inflection.demodulize(self.name))
          self.association_name = type.pluralize.to_sym
          self.content_type = type.to_sym
          # Let's generate a label from the class — this might be over-ridden later
          self.label = Extlib::Inflection.humanize(type)
        end
        
        # This registers this class so that the page can later query which 
        # classes it needs to be aware of.
        Gluttonberg::Content.register_as_content(klass)
      end
    
      module ClassMethods
        # TODO: Have this create an alias between the parent and localization's
        # properties. Maybe use the Delegate model.
        def is_localized(&blk)
          self.localized = true
        
          # Generate the localization model
          class_name = "#{Extlib::Inflection.demodulize(self.name)}Localization"
          storage_name = Extlib::Inflection.tableize(class_name)
          localized_model = DataMapper::Model.new(storage_name)
          Gluttonberg.const_set(class_name, localized_model)
        
          # Mix in our base set of properties and methods
          localized_model.send(:include, Gluttonberg::Content::Localization)
          # Generate additional properties from the block passed in
          localized_model.class_eval(&blk)
          # Store the name so we can easily access it without having to look 
          # at this parent class
          localized_model.content_type = self.content_type
        
          # Set up filters on the class to make sure the localization gets migrated
          self.after_class_method(:auto_migrate!) { localized_model.auto_migrate! }
          self.after_class_method(:auto_upgrade!) { localized_model.auto_upgrade! }
          
          # Tell the content module that we are localized
          localized_model.association_name = :"#{self.content_type}_localizations"
          Gluttonberg::Content.register_localization(localized_model.association_name, localized_model)
        
          # Set up the associations
          has n, :localizations, :class_name => Gluttonberg.const_get(class_name)
          localized_model.belongs_to(:parent, :class_name => self.name)
        end
        
        # Does this class have an associated localization class.
        def localized?
          self.localized
        end
        
        # Returns all the matching models with the specificed localization loaded.
        def all_with_localization(opts)
          page_localization_id = opts.delete(:page_localization_id)
          results = all(opts)
          results.each { |r| r.load_localization(page_localization_id) }
          results
        end
      end
      
      module InstanceMethods
        def localized?
          self.class.localized?
        end
        
        # Just delegates to the class.
        def content_type
          self.class.content_type
        end
        
        # Loads a localized version based on the specified page localization,
        # then stashes it in an accessor
        def load_localization(id_or_model)
          if localized?
            id = id_or_model.is_a?(Numeric) ? id_or_model : id_or_model.id
            @current_localization = localizations.first(:page_localization_id => id)
          end
        end
      end
    end
  end
end