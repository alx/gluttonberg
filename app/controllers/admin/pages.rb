module Admin
  class Pages < Application
    include AdminController
    
    before :find_page, :only => [:show, :edit, :delete, :update, :destroy]
    
    def index
      @pages = Page.all(:parent_id => nil)
      display @pages
    end
  
    def show
      @page = Page.get(params[:id])
      raise NotFound unless @page
      display @page
    end
  
    def new
      only_provides :html
      @page = Page.new
      @page_localization = PageLocalization.new
      prepare_to_edit
      render
    end
  
    def edit
      only_provides :html
      prepare_to_edit
      render
    end
    
    def delete
      display_delete_confirmation(
        :title      => "Delete “#{@page.name}” page?",
        :action     => url(:admin_page, @page),
        :return_url => url(:admin_page, @page)
      )
    end
  
    def create
      @page = Page.new(params[:page])
      # localization_params = params[:page_localization].merge(:name => params[:page][:name], :slug => params[:page][:slug])
      #       @page_localization = PageLocalization.new(localization_params)
      #       @page.localizations << @page_localization
      # Create a default localization based on the user's choices
      if @page.save
        redirect url(:admin_page, @page)
      else
        prepare_to_edit
        render :new
      end
    end
  
    def update
      if @page.update_attributes(params[:page]) || !@page.dirty?
        redirect url(:admin_page, @page)
      else
        raise BadRequest
      end
    end
  
    def destroy
      if @page.destroy
        redirect url(:admin_pages)
      else
        raise BadRequest
      end
    end
    
    private
    
    def prepare_to_edit
      @pages      = params[:id] ? Page.all(:id.not => params[:id]) : Page.all
      @dialects   = Dialect.all
      @templates  = Template.views
      @layouts    = Template.layouts
      @locales    = Locale.all
    end
    
    def find_page
      @page = Page.get(params[:id])
      raise NotFound unless @page
    end
  end
end # Admin
