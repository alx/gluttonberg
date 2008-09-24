module Glutton
  module Content
    # This module can be mixed into a class to make it behave like a content 
    # block. A content block is a class that can be associated with a section
    # on a page.
    module Block
      def self.included(klass)
        klass.class_eval do
          extend Block::ClassMethods
          include Block::InstanceMethods
          
          @@localized = false
          
          property :section_name, String,                       :length => 1..255
          property :orphaned,     ::DataMapper::Types::Boolean, :default => false
          property :created_at,   Time
          property :updated_at,   Time 
          
          belongs_to :page
          belongs_to :section, :class_name => "TemplateSection"
        end
        
        # This registers this class so that the page can later query which 
        # classes it needs to be aware of.
        Glutton::Content.register_as_content(klass)
      end
    
      module ClassMethods
        # Short-hand for setting up the association to the 
        def has_localizations(model_name)
          @@localized = true
          has n, :localizations, :class_name => Extlib::Inflection.classify(model_name.to_s), :dependent => :destroy
        end
        
        # Does this class have an associated localization class.
        def localized?
          @@localized
        end
      end
      
      module InstanceMethods
        
      end
    end
  end
end