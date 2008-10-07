module Gluttonberg
  module Content
    class PageLocalizations < Gluttonberg::Application
      include Gluttonberg::AdminController
      # provides :xml, :yaml, :js

      def index
        @page_localizations = PageLocalization.all
        display @page_localizations
      end

      def new
        only_provides :html
        @page_localization = PageLocalization.new
        @page = Page.get(params[:page_id])
        records_for_editing
        render
      end

      def edit
        only_provides :html
        @page_localization = PageLocalization.get(params[:id])
        raise NotFound unless @page_localization
        records_for_editing
        render
      end

      def create
        @page_localization = PageLocalization.new(params[:page_localization])
        @page_localization.page = Page.get(params[:page_id])
        if @page_localization.save
          redirect url(:page, params[:page_id])
        else
          records_for_editing
          render :new
        end
      end

      def update
        @page_localization = PageLocalization.get(params[:id])
        raise NotFound unless @page_localization
        if @page_localization.update_attributes(params[:page_localization]) || !@page_localization.dirty?
          redirect url(:admin, params[:page_id])
        else
          records_for_editing
          render :edit
        end
      end

      def destroy
        @page_localization = PageLocalization.get(params[:id])
        raise NotFound unless @page_localization
        if @page_localization.destroy
          redirect url(:page_localization)
        else
          raise BadRequest
        end
      end

      private

      def records_for_editing
        @dialects = Dialect.all
        @locales = Locale.all
      end
      
    end
  end  
end
