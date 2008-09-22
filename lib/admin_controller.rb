module AdminController
  def self.included(klass)
    klass.class_eval do
      layout :admin
    end
  end
  
  def display_delete_confirmation(opts)
    @options = opts
    @options[:title]    ||= "Delete Record?"
    @options[:message]  ||= "If you delete this record, it will be gone permanently. There is no undo."
    render :template => "admin/shared/delete", :layout => false
  end
end