module Gluttonberg
  module Content
    class TemplateSections < Application
      include Gluttonberg::AdminController

      before :find_template
      before :find_template_section, :only => [:show, :edit, :delete, :update, :destroy]

      def index
        @sections = @template.sections
        display @sections
      end

      def new
        only_provides :html
        @template_section = TemplateSection.new
        render
      end

      def edit
        only_provides :html
        render
      end

      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@template_section.name}” section?",
          :action     => url(:template_section, :id => @template_section, :template_id => @template),
          :return_url => url(:template_sections, :template_id => @template)
        )
      end

      def create
        @template_section = @template.sections.build(params[:template_section])
        if @template_section.save
          redirect url(:template_sections, :template_id => @template)
        else
          render :new
        end
      end

      def update
        if @template_section.update_attributes(params[:template_section]) || !@template_section.dirty?
          redirect url(:template_sections, :template_id => @template)
        else
          raise BadRequest
        end
      end

      def destroy
        if @template_section.destroy
          redirect url(:template_sections, :template_id => @template)
        else
          raise BadRequest
        end
      end

      private

      def find_template
        @template = Template.get(params[:template_id])
      end

      def find_template_section
        @template_section = @template.sections.get(params[:id])
        raise NotFound unless @template_section
      end

    end
  end
end
