module Locomotive
  class PreviewsController < BaseController
    include Locomotive::Routing::SiteDispatcher
    include Locomotive::Render
    include Locomotive::ActionController::LocaleHelpers

    sections 'contents'


    def new
      @page = current_site.pages.find(params[:page_id])
      @preview = current_site.previews.build(page_params: params[:page])
      @page.attributes = params[:page]
      prepare_toolbar
      render_locomotive_page(nil, { page: @page, no_redirect: true, toolbar: @toolbar })
    end

    def show
      @preview = current_site.previews.find(params[:id])
      @page = @preview.page
      @page.attributes = JSON.parse(@preview.page_params)
      prepare_toolbar
      render_locomotive_page(nil, { page: @page, no_redirect: true, toolbar: @toolbar })
    end

    def create
      @preview = current_site.previews.build(params[:preview])
      @page = current_site.pages.find(params[:page_id])
      if can?(:update, @page)
        new_attributes = JSON.parse(@preview.page_params)
        @page.update_attributes(new_attributes)
      else
        @preview.page_id = @page.id
        @preview.account_id = current_locomotive_account.id
        @preview.save
      end
      redirect_to edit_page_path(@page._id)
    end

    def update
      @preview = current_site.previews.find(params[:id])
      return destroy if params[:commit] == Locomotive::Preview::REJECT_TEXT
      @page = current_site.pages.find(params[:page_id])
      @page.update_attributes(JSON.parse(@preview.page_params))
      destroy
    end

    def index
      @previews = current_site.previews.includes([:page, :account])
    end

    def destroy
      @preview.destroy
      redirect_to previews_pages_path
    end

    private

      def prepare_toolbar
        @toolbar = render_to_string partial: "locomotive/previews/toolbar"
      end

  end
end

