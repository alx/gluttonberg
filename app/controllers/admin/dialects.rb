module Admin
  class Dialects < Application
    include AdminController
    
    before :find_dialect, :only => [:delete, :edit, :delete, :update, :destroy]
  
    def index
      @dialects = Dialect.all
      display @dialects
    end
  
    def new
      only_provides :html
      @dialect = Dialect.new
      render
    end
  
    def edit
      render
    end
  
    def delete
      display_delete_confirmation(
        :title      => "Delete “#{@dialect.name}” dialect?",
        :action     => url(:admin_dialect, @dialect),
        :return_url => url(:admin_dialects)
      )
    end
  
    def create
      @dialect = Dialect.new(params[:dialect])
      if @dialect.save
        redirect url(:admin_dialects)
      else
        render :new
      end
    end
  
    def update
      if @dialect.update_attributes(params[:dialect]) || !@dialect.dirty?
        redirect url(:admin_dialects)
      else
        render :edit
      end
    end
  
    def destroy
      if @dialect.destroy
        redirect url(:admin_dialects)
      else
        raise BadRequest
      end
    end
  
    private
    
    def find_dialect
      @dialect = Dialect.get(params[:id])
      raise NotFound unless @dialect
    end
  
  end
end