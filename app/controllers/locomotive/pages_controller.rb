module Locomotive
  class PagesController < BaseController

    sections 'contents'

    localized

    before_filter :back_to_default_site_locale, only: %w(new create)

    respond_to    :json, only: [:show, :create, :update, :sort, :get_path]

    def index
      @pages = current_site.all_pages_in_once
      respond_with(@pages)
    end

    def show
      @page = current_site.pages.find(params[:id])
      @page.attributes = JSON.parse(params[:page_params]) if params[:page_params]
      respond_with @page
    end

    def new
      @page = current_site.pages.build
      respond_with @page
    end

    def create
      @page = current_site.pages.new(params[:page])
      updated_params = Locomotive::Page::MeritasParser.new(page: @page, params: params).updated_params
      @page = current_site.pages.create(updated_params[:page])
      respond_with @page, location: edit_page_path(@page._id)
    end

    def edit
      @page = current_site.pages.find(params[:id])
      session[:access_type] = @page.belongs_to_portal? ? Locomotive::PublicResource::AccessTypes::PORTAL : Locomotive::PublicResource::AccessTypes::PUBLIC

      if from_preview?
        @page.attributes = JSON.parse(params[:page_params])
        # calling .valid? will serialize the template
        @page.valid?
      end
      respond_with @page
    end

    def update
      @page = current_site.pages.find(params[:id])
      updated_params = Locomotive::Page::MeritasParser.new(page: @page, params: params).updated_params
      @page.update_attributes(updated_params[:page])
      respond_with @page, location: edit_page_path(@page._id)
    end

    def destroy
      @page = current_site.pages.find(params[:id])
      @page.destroy
      respond_with @page
    end

    def sort
      @page = current_site.pages.find(params[:id])
      @page.sort_children!(params[:children])
      respond_with @page
    end

    def get_path
      page = current_site.pages.build(parent: current_site.pages.find(params[:parent_id]), slug: params[:slug].permalink).tap do |p|
        p.valid?; p.send(:build_fullpath)
      end
      render json: {
        url:                public_page_url(page, locale: current_content_locale),
        slug:               page.slug,
        templatized_parent: page.templatized_from_parent?
      }
    end

    def from_preview?
      params[:page_params].present?
    end

  end
end
