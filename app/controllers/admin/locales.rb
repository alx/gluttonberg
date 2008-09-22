module Admin
  class Locales < Application
    include AdminController
    # provides :xml, :yaml, :js
  
    def index
      @locales = Locale.all(:order => [:name.asc])
      display @locales
    end
  
    def new
      only_provides :html
      @locale   = Locale.new
      prepare_to_edit
      render
    end
  
    def edit
      only_provides :html
      @locale = Locale.get(params[:id])
      raise NotFound unless @locale
      prepare_to_edit
      render
    end
  
    def delete
      only_provides :html
      @locale = Locale.get(params[:id])
      raise NotFound unless @locale
      display_delete_confirmation(
        :title      => "Delete the “#{@locale.name}” locale?",
        :action     => url(:admin_locale, @locale),
        :return_url => url(:admin_locales)
      )
    end
  
    def create
      @locale = Locale.new(params[:locale])
      if @locale.save
        redirect url(:admin_locales)
      else
        prepare_to_edit
        render :new
      end
    end
  
    def update
      @locale = Locale.get(params[:id])
      raise NotFound unless @locale
      if @locale.update_attributes(params[:locale]) || !@locale.dirty?
        redirect url(:admin_locales)
      else
        prepare_to_edit
        render :edit
      end
    end
  
    def destroy
      @locale = Locale.get(params[:id])
      raise NotFound unless @locale
      if @locale.destroy
        redirect url(:admin_locales)
      else
        raise BadRequest
      end
    end
  
    private
    
    # Grabs the various model collections we need when editing or updating a record
    def prepare_to_edit
      locale_opts = {:order => [:name.desc]}
      locale_opts[:id.not] = @locale.id unless @locale.new_record?
      @locales  = Locale.all(locale_opts)
      @dialects = Dialect.all
    end
  end
end # Admin
