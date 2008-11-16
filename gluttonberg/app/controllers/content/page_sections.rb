module Gluttonberg
  module Content
    class PageSections < Gluttonberg::Application
      include AdminController
      
      before :find_page_type
      before :find_page_section, :exclude => [:index, :new, :create]
    
      def index
        @page_sections = @page_type.sections.all
        display @page_sections
      end
    
      def new
        only_provides :html
        @page_section = PageSection.new
        render
      end
    
      def edit
        only_provides :html
        render
      end
    
      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@page_section.name}”?",
          :action     => slice_url(:page_type, @page_section),
          :return_url => slice_url(:page_types)
        )
      end
    
      def create
        @page_section = @page_type.sections.build(params["gluttonberg::page_section"])
        if @page_section.save
          redirect slice_url(:page_type_sections, params[:type_id])
        else
          render :new
        end
      end
    
      def update
        if @page_section.update_attributes(params["gluttonberg::page_section"]) || !@page_section.dirty?
          redirect slice_url(:page_types)
        else
          raise BadRequest
        end
      end
    
      def destroy
        if @page_section.destroy
          redirect slice_url(:page_types)
        else
          raise BadRequest
        end
      end

      private
      
      def find_page_section
        @page_section = PageSection.first(:id => params[:id])
        raise NotFound unless @page_section
      end
   
      def find_page_type
        @page_type = PageType.get(params[:type_id])
        raise NotFound unless @page_type
      end
    
    end
    
  end
end