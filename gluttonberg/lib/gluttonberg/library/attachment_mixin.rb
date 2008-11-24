module Gluttonberg
  module Library
    module AttachmentMixin
      def self.included(klass)
        klass.class_eval do
          property :name,         String
          property :description,  DataMapper::Types::Text
          property :file_name,    String, :length => 255
          property :hash,         String, :length => 255, :writer => :private
          property :size,         Integer
          
          after   :destroy, :remove_file_from_disk
          before  :save,    :generate_reference_hash
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
      
      def url
        "/assets/#{hash}/#{file_name}"
      end
      
      def location_on_disk
        directory / file_name
      end
      
      def directory
        Library.root / hash
      end

      private

      def remove_file_from_disk
        if File.exists?(directory)
          FileUtils.rm_r(directory) 
        end
      end

      def update_file_on_disk
        if file
          FileUtils.mkdir(directory) unless File.exists?(directory)
          FileUtils.mv file[:tempfile].path, location_on_disk
        end
      end
      
      private
      
      def generate_reference_hash
        unless attribute_get(:hash)
          attribute_set(:hash, Digest::SHA1.hexdigest(Time.now.to_s + file_name))
        end
      end
    end
  end
end