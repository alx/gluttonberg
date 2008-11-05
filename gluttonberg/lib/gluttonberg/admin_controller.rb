module Gluttonberg
  module AdminController
    def display_delete_confirmation(opts)
      @options = opts
      @options[:title]    ||= "Delete Record?"
      @options[:message]  ||= "If you delete this record, it will be gone permanently. There is no undo."
      render :template => "shared/delete", :layout => false
    end

    def self.included(klass)
      klass.class_eval do
        before :ensure_authenticated
      end
    end 
  end
end