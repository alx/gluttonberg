module Gluttonberg
  module Content
    class Layouts < Gluttonberg::Application
      include Gluttonberg::AdminController

      before :find_layout, :exclude => [:index, :new, :create]
      
      def index
        @layouts = Layout.all
        display @layouts
      end
      
      def new
        @layout = Layout.new
        render
      end
      
      def edit
        render
      end
      
      def delete
        delete_confirmation(
          
        )
      end
      
      def create
        @layout = Layout.new(params["gluttonberg::layout"])
        if @layout.save
          redirect(slice_url(:layouts))
        else
          render :new
        end
      end
      
      def update
        if @layout.update_attributes(params["gluttonberg::layout"])
          redirect(slice_url(:layouts))
        else
          render :edit
        end
      end
      
      def destroy
        
      end
      
      private
      
      def find_layout
        @layout = Layout.get(params[:id])
        raise NotFound unless @layout
      end
    end
  end
end