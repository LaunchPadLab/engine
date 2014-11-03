module Locomotive
  class PreviewsController < BaseController
    include Locomotive::Routing::SiteDispatcher
    include Locomotive::Render
    include Locomotive::ActionController::LocaleHelpers

    sections 'contents'


    def new
      @page = current_site.pages.find(params[:page_id])
      template_name = params[:page][:template_name]
      if template_name.present? && !@page.extendable
        raw_template = params[:page][:raw_template]
        string_to_replace = raw_template[/\{\% extends (.*?) %/,1]
        raw_template.sub!(string_to_replace, template_name)
      end
      @preview = current_site.previews.build(page_params: params[:page].to_json)
      @page.attributes = params[:page]
      return redirect_to edit_page_path(@page) if @page.invalid?
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
        current_site.previews.where(page: @page).destroy_all
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

