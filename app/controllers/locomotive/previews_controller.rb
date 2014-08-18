module Locomotive
  class PreviewsController < ApplicationController
    include Locomotive::Routing::SiteDispatcher
    include Locomotive::Render
    include Locomotive::ActionController::LocaleHelpers

    def create
      page = current_site.pages.find(params[:page_id])
      @page = page.dup
      @page.attributes = params[:page]
      preview = current_site.previews.create(site_id: page.site.id, page_id: params[:page_id], params: params[:page])
      render_locomotive_page(nil, { page: @page, no_redirect: true })
    end

    def show
      @preview = current_site.previews.find(params[:preview_id])

    end

  end
end

