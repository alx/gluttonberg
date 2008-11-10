module Gluttonberg
  module AdminController
    def self.included(klass)
      klass.class_eval do
        self._template_roots << [Gluttonberg.root / "app" / "views", :_template_location]
        layout("gluttonberg")
      end
    end
    
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