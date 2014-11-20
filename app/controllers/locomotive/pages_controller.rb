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
      template_name = params[:page][:template_name]
      if template_name.present?
        raw_template = params[:page][:raw_template]
        string_to_replace = raw_template[/\{\% extends (.*?) %/,1]
        raw_template.sub!(string_to_replace, template_name)
      end
      @page = current_site.pages.create(params[:page])
      respond_with @page, location: edit_page_path(@page._id)
    end

    def edit
      @page = current_site.pages.find(params[:id])
      session[:access_type] = @page.belongs_to_intranet? ? Locomotive::PublicResource::AccessTypes::PORTAL : Locomotive::PublicResource::AccessTypes::PUBLIC

      if from_preview?
        @page.attributes = JSON.parse(params[:page_params])
        # calling .valid? will serialize the template
        @page.valid?
      end
      respond_with @page
    end

    def update
      @page = current_site.pages.find(params[:id])
      template_name = params[:page][:template_name]
      if template_name.present? && !@page.extendable
        raw_template = params[:page][:raw_template]
        string_to_replace = raw_template[/\{\% extends (.*?) %/,1]
        raw_template.sub!(string_to_replace, template_name)
      end
      @page.update_attributes(params[:page])
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
