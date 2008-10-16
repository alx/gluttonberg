module Gluttonberg
  module Content
    class PageTypes < Gluttonberg::Application
      include AdminController
      
      before :find_page_type, :exclude => [:index, :new, :create]
    
      def index
        @page_types = PageType.all
        display @page_types
      end
    
      def new
        only_provides :html
        @page_type = PageType.new
        render
      end
    
      def edit
        only_provides :html
        render
      end
    
      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@page_type.name}”?",
          :action     => slice_url(:page_type, @page_type),
          :return_url => slice_url(:page_types)
        )
      end
    
      def create
        @page_type = PageType.new(params["gluttonberg::page_type"])
        if @page_type.save
          redirect slice_url(:page_types)
        else
          render :new
        end
      end
    
      def update
        if @page_type.update_attributes(params["gluttonberg::page_type"]) || !@page_type.dirty?
          redirect slice_url(:page_types)
        else
          raise BadRequest
        end
      end
    
      def destroy
        if @page_type.destroy
          redirect slice_url(:page_types)
        else
          raise BadRequest
        end
      end

      private
      
      def find_page_type
        @page_type = PageType.get(params[:id])
        raise NotFound unless @page_type
      end
    
    end
  end
end
