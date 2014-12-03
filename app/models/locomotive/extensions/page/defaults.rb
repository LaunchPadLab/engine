module Locomotive
  module Extensions
    module Page
      class Defaults

        attr_reader :site

        REQUIRED_PATHS = ['portal', 'portal/users', 'portal/users/sign_in', 'portal/users/new']

        def initialize(args = {})
          @site = args[:site]
          @path = args[:path]
        end

        def create
          return unless should_create_page?
          site.pages.create(page_properties)
        end

        def home_id
          site.pages.where(slug: 'index').first._id
        end

        def page_properties
          {}
        end

        def should_create_page?
          site.pages.where(fullpath: path).first.nil?
        end

      end
    end
  end
end
