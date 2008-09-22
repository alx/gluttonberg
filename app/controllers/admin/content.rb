module Admin
  class Content < Application
    include AdminController
    
    def index
      render
    end
  end
end