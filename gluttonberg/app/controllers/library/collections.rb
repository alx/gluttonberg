module Gluttonberg
  module Library
    class Collections < Gluttonberg::Application
      include Gluttonberg::AdminController
      
      before :find_collection, :exclude => [:index, :new, :create]

      def index
        @collections = AssetCollection.all
        display @collections
      end
      
      def new
        @collection = AssetCollection.new
        render
      end
      
      def edit
        render
      end

      def add_asset
        only_provides :json
        

        @asset = Asset.get(params[:asset_id])
        raise NotFound unless @asset

        # add the asset to the collection
        @collection.assets << @asset
        @collection.save

        JSON.pretty_generate({
          :success => true
        })
      end
      
      def show
        provides :json
        @assets = @collection.assets.all(:order => [:name.desc])
        if content_type == :json
          JSON.pretty_generate({
            :name     => @collection.name,
            :backURL  => slice_url(:asset_browser, :no_frame => false),
            :markup   => partial("library/shared/asset_panels", :format => :html, :editing => false)
          })
        else
          render
        end
      end
      
      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@collection.name}”?",
          :action     => slice_url(:collection, @collection),
          :return_url => slice_url(:collection, @collection)
        )
      end
      
      def create
        @collection = AssetCollection.new(params["gluttonberg::asset_collection"])
        if @collection.save
          redirect(slice_url(:library))
        else
          render :new
        end
      end
      
      def update
        if @collection.update_attributes(params["gluttonberg::asset_collection"])
          redirect(slice_url(:library))
        else
          render :new
        end
      end
      
      def destroy
        @collection.destroy
        redirect(slice_url(:library))
      end
      
      private
      
      def find_collection
        @collection = AssetCollection.get(params[:id])
        raise NotFound unless @collection
      end
    end
  end
end