module Gluttonberg
  class RichTextContent
    include DataMapper::Resource
    include Gluttonberg::Content::Block

    property :id, Serial
            
    is_localized do
      property :text,           Text
      property :formatted_text, Text, :writer => :private
      
      before :save, :convert_textile_text_to_html
      
      private
      
      def convert_textile_text_to_html
        if new_record? || attribute_dirty?(:text)
          attribute_set(:formatted_text, RedCloth.new(text).to_html)
        end
      end
    end
  end
end