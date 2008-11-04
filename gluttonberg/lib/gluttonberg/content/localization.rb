module Gluttonberg
  module Content
    module Localization
      def self.included(klass)
        klass.class_eval do
          class << self; attr_accessor :content_type end
          
          property :id,         ::DataMapper::Types::Serial
          property :created_at, Time
          property :updated_at, Time

          belongs_to :page_localization
        end
      end
      
      def section_name
        parent.section.name
      end
      
      def section_label
        parent.section.label
      end
    end
  end
end