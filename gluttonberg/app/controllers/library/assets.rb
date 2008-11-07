module Gluttonberg
  module Library
    class Assets < Gluttonberg::Application
      include Gluttonberg::AdminController
      
      before :find_asset, :exclude => [:index, :category, :new, :create, :browser]

      def index
        @assets = Asset.all
        display @assets
      end
      
      def browser
        @assets = []
        @collections = AssetCollection.all(:order => [:name.desc])
        render :layout => false
      end
      
      def category
        provides :json
        @assets = Asset.all(:category => params[:category], :order => [:name.desc])
        if content_type == :json
          JSON.pretty_generate({
            :name       => params[:category].pluralize.capitalize,
            :depth      => 1,
            :markup     => partial("library/shared/asset_panels", :format => :html, :editing => false)
          })
        else
          render
        end
      end
      
      def show
        render
      end
      
      def new
        @asset = Asset.new
        prepare_to_edit
        render
      end
      
      def edit
        prepare_to_edit
        render
      end
      
      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@asset.name}”?",
          :action     => slice_url(:asset, @asset),
          :return_url => slice_url(:asset, @asset)
        )
      end
      
      def create
        @asset = Asset.new(params["gluttonberg::asset"])
        if @asset.save
          redirect(slice_url(:library))
        else
          prepare_to_edit
          render :new
        end
      end
      
      def update
        if @asset.update_attributes(params["gluttonberg::asset"])
          redirect(slice_url(:library))
        else
          prepare_to_edit
          render :new
        end
      end
      
      def destroy
        @asset.destroy
        redirect(slice_url(:library))
      end
      
      private
      
      def find_asset
        @asset = Asset.get(params[:id])
        raise NotFound unless @asset
      end
      
      def prepare_to_edit
        @dialects = Dialect.all
        @locales = Locale.all
      end
    end
  end
end