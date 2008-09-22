module Admin
  class Articles < Application
    include AdminController
    # provides :xml, :yaml, :js
  
    def index
      @articles = Article.all
      display @articles
    end
  
    def show
      @article = Article.get(params[:id])
      raise NotFound unless @article
      display @article
    end
  
    def new
      only_provides :html
      @article = Article.new
      @article_localization = ArticleLocalization.new
      @page = Page.get(params[:page_id])
      @page_localizations = @page.localizations
      render
    end
  
    def edit
      only_provides :html
      @article = Article.get(params[:id])
      raise NotFound unless @article
      render
    end
  
    def create
      @article = Article.new(params[:article].merge(:page_id => params[:page_id]))
      @article_localization = ArticleLocalization.new(:title => params[:article][:title], :body => params[:article][:body])
      @article.localizations << @article_localization
      if @article.save
        redirect url(:admin_article, @article)
      else
        render :new
      end
    end
  
    def update
      @article = Article.get(params[:id])
      raise NotFound unless @article
      if @article.update_attributes(params[:article]) || !@article.dirty?
        redirect url(:admin_article, @article)
      else
        raise BadRequest
      end
    end
  
    def destroy
      @article = Article.get(params[:id])
      raise NotFound unless @article
      if @article.destroy
        redirect url(:admin_article)
      else
        raise BadRequest
      end
    end
  
  end
end # Admin
