module Gluttonberg
  module Content
    module Textilized
      def self.included(klass)
        klass.class_eval do
          class << self; attr_accessor :textilized_fields end
          extend ClassMethods
          include InstanceMethods
        end
        
      end
      
      module ClassMethods
        def is_textilized(*fields)
          self.textilized_fields = {}
          fields.each do |field|
            self.textilized_fields[field] = :"formatted_#{field}"
            property :"formatted_#{field}", DataMapper::Types::Text, :writer => :private
          end
          before :save, :convert_textile_text_to_html
        end
      end
      
      module InstanceMethods
        private

        def convert_textile_text_to_html
          self.class.textilized_fields.each do |field, formatted_field|
            if attribute_dirty?(field)
              attribute_set(formatted_field, RedCloth.new(text).to_html)
            end
          end
        end
      end
    end
  end
end