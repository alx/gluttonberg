module Gluttonberg
  module Content
    class Templates < Gluttonberg::Application
      include Gluttonberg::AdminController

      before :find_template, :only => [:show, :edit, :delete, :update, :destroy]

      def index
        @templates = Template.views
        @layouts = Template.layouts
        render
      end

      def new
        only_provides :html
        @template = Template.new
        render
      end

      def edit
        only_provides :html
        render
      end

      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@template.name}” template?",
          :action     => slice_url(:template, @template),
          :return_url => slice_url(:templates)
        )
      end

      def create
        @template = Template.new(params["gluttonberg::template"])
        if @template.save
          redirect slice_url(:templates)
        else
          render :new
        end
      end

      def update
        if @template.update_attributes(params["gluttonberg::template"])
          redirect slice_url(:templates)
        else
          render :edit
        end
      end

      def destroy
        if @template.destroy
          redirect slice_url(:templates)
        else
          raise BadRequest
        end
      end

      private

      def find_template
        @template = Template.get(params[:id])
        raise NotFound unless @template
      end

    end
    
  end
end
