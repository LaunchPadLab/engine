module Locomotive
  class Page::MeritasParser

    attr_reader :page
    attr_accessor :params


    def initialize(args = {})
      @params = args[:params]
      @page = args[:page]
    end

    def updated_params
      update_template_name
      @params
    end

      private

        # EMBED SELECTED TEMPLATE NAME IN RAW TEMPLATE
        # i.e. {% extends 'template-name-here' %}
        def update_template_name
          return unless selected_template_name.present?
          raw_template = params[:page][:raw_template]
          string_to_replace = raw_template[/\{\% extends (.*?) %/,1]
          raw_template.sub!(string_to_replace, template_name)
        end

        def template_name
          return selected_template_name unless page_belongs_to_portal?
          return portalize_template_name if should_be_portalized?
          selected_template_name
        end

        def selected_template_name
          params[:page][:template_name].try(:downcase)
        end

        def portalize_template_name
          hash = {
            "content-one-column" => "portal-content-one-column",
            "content-two-columns" => "portal-content-two-columns",
            "content-three-columns" => "portal-content-three-columns"
          }
          hash[selected_template_name] || selected_template_name
        end

        def should_be_portalized?
          selected_template_name[0..5] != "portal" && !public_portal_page?
        end

        def page_belongs_to_portal?
          page.belongs_to_portal? || (page.parent && page.parent.belongs_to_portal?)
        end

        def public_portal_page?
          page.fullpath.split("/").include?("users")
        end

  end
end