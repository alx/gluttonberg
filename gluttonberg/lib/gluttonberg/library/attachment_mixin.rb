module Gluttonberg
  module Library
    module AttachmentMixin
      def self.included(klass)
        klass.class_eval do
          property :name,         String
          property :description,  DataMapper::Types::Text
          property :file_name,    String, :length => 255
          property :size,         Integer
          
          after :destroy, :remove_file_from_disk
        end
      end
      
      def file=(new_file)
        unless new_file.blank?
          # Forgive me this naive sanitisation, I'm still a regex n00b
          clean_filename = new_file[:filename].gsub(" ", "_").gsub(/[^A-Za-z0-9\-_.]/, "").downcase
          attribute_set(:file_name, clean_filename)
          attribute_set(:size, new_file[:size])
          @file = new_file
        end
      end
      
      def file
        @file
      end

      def location_on_disk
        Library.assets_dir(category) / file_name
      end

      private

      def remove_file_from_disk
        FileUtils.rm(location_on_disk) if File.exists?(location_on_disk)
      end

      def update_file_on_disk
        if file
          FileUtils.mv file[:tempfile].path, location_on_disk
        end
      end
    end
  end
end