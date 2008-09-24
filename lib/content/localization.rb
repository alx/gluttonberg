module Glutton
  module Content
    module Localization
      def self.included(klass)
        klass.class_eval do
          extend Localization::ClassMethods
          
          property :created_at,   Time
          property :updated_at,   Time

          belongs_to :localization, :class_name => "PageLocalization"
        end
      end
      
      module ClassMethods
        def localizes(name)
          belongs_to :parent, :class_name => Extlib::Inflection.classify(name.to_s)
        end
      end
    end
  end
end