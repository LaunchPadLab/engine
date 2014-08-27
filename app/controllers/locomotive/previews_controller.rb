module Locomotive
  class PreviewsController < ApplicationController
    include Locomotive::Routing::SiteDispatcher
    include Locomotive::Render
    include Locomotive::ActionController::LocaleHelpers

    def new
      @page = current_site.pages.find(params[:page_id])
      @page.attributes = params[:page]
      @preview = current_site.previews.build(page_params: params[:page])
      toolbar = render_to_string partial: "locomotive/previews/toolbar"
      render_locomotive_page(nil, { page: @page, no_redirect: true, toolbar: toolbar })
    end

    def show
      @preview = current_site.previews.find(params[:preview_id])
    end

    def create
      @preview = current_site.previews.build(params[:preview])
      @page = current_site.pages.find(params[:page_id])
      new_attributes = JSON.parse(params[:preview][:page_params])
      @page.update_attributes(new_attributes)
      redirect_to edit_page_path(@page._id)
    end

    def update

    end

  end
end

