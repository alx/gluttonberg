module Gluttonberg
  module Content
    module Localization
      def self.included(klass)
        klass.class_eval do
          property :id,         ::DataMapper::Types::Serial
          property :created_at, Time
          property :updated_at, Time

          belongs_to :page_localization
        end
      end
    end
  end
end