require File.join( File.dirname(__FILE__), '../..', "spec_helper" )
require Merb.root / "app" / "observers" / "page_observer"
require Merb.root / "app" / "observers" / "page_localization_observer"

module Gluttonberg
  # Fixtures to be shared across tests
  10.of { Dialect.generate }
  3.of  { Locale.generate }
  3.of  { Layout.generate }
  8.of  { PageType.generate }

  module AdminPagesSpecHelper
    def page_params(opts)
      page = {
        :name         => "About Us",
        :slug         => "about",
        :layout_id    => Template.pick(:layout).id,
        :template_id  => Template.pick(:view).id
      }
      page[:name] = '' if !opts[:saves]
      page
    end

    def generate_pages
      5.of  { Page.generate(:parent) }
      12.of { Page.generate(:child) }

      #generate_page_articles(Page.all)
    end

    def generate_page
      @page = Page.generate(:parent)
      #generate_page_articles([@page])
    end

    # This is cumbersome looking, but it's the only way I could think of
    # generating the associated records. In the future I might investigate a 
    # neater way of doing it.
    def generate_page_articles(pages)
      pages.each do |page|
        # Based on the template, generate the content
        page.type.sections.each do |section|
          association = section.send(section.type)
          association.create(:section => section, :page => page)
        end
        # Generate the localizations
        Locale.all.each do |locale|
          locale.dialects.all.each do |dialect|
            localization = PageLocalization.generate(:locale => locale, :dialect => dialect)
            page.localizations << localization
            # For each article in the page, create a corresponding one for the localization
            page.articles.each do |article|
              article.localizations << ArticleLocalization.generate
            end
          end
        end
        page.save
      end
    end
  end
  
  module Content
    describe Content::Pages do
      include AdminPagesSpecHelper

      it "should display pages in index" do
        generate_pages
        controller = dispatch_to(Pages, :index)
        controller.should be_successful
      end

      it "should show page" do
        generate_page
        controller = dispatch_to(Pages, :show, :id => @page.id)
        controller.should be_successful
        controller.assigns(:page).should == @page
      end

      it "should display edit form" do
        generate_page
        controller = dispatch_to(Pages, :edit, :id => @page.id)
        controller.should be_successful
        controller.body.should have_selector("#wrapper form")
      end

      it "should display new form" do
        controller = dispatch_to(Pages, :new)
        controller.should be_successful
        controller.body.should have_selector("#wrapper form")
      end

      it "should display delete confirmation" do
        generate_page
        controller = dispatch_to(Pages, :delete, :id => @page.id)
        controller.should be_successful
        controller.body.should have_selector("#delete form")
      end

      it "should destroy page" do
        generate_page
        controller = dispatch_to(Pages, :destroy, :id => @page.id)
        controller.should be_redirection_to("/admin/content/pages")
        Page.get(@page.id).should be_nil
      end

    end

    describe Pages, "create" do
      include AdminPagesSpecHelper

      it "should create page" do
        controller = dispatch_to(Pages, :create, :page => page_params(:saves => true))
        controller.should be_redirection
      end

      it "should show form if create fails" do
        controller = dispatch_to(Pages, :create, :page => page_params(:saves => false))
        controller.should be_successful
        controller.body.should have_selector("#wrapper form div.error")
      end

    end

    describe Pages, "update" do
      include AdminPagesSpecHelper

      before(:all) { generate_page }

      it "should update page" do
        controller = dispatch_to(Pages, :update, :id => @page.id, :page => page_params(:saves => true))
        controller.should be_redirection_to("/admin/content/pages/#{@page.id}")
      end

      it "should show form if update fails" do
        controller = dispatch_to(Pages, :update, :id => @page.id, :page => page_params(:saves => false))
        controller.should be_successful
        controller.body.should have_selector("#wrapper form div.error")
      end

    end
  end
end