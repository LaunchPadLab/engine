module Locomotive
  module PublicApi
    class ContentEntriesController < BaseController

      def index
        @content_type = current_site.content_types.where(slug: params[:slug]).first
        @content_entries = @content_type.entries.order_by([@content_type.order_by_definition])
        @content_entries = Locomotive::Meritas::Api::ContentEntry.new(content_entries: @content_entries, params: params, content_type: @content_type, site: current_site).entries
        respond_with @content_entries
      end

      def page_count
        @content_type = current_site.content_types.where(slug: params[:slug]).first
        @content_entries = @content_type.entries.order_by([@content_type.order_by_definition])
        page_count = Locomotive::Meritas::Api::ContentEntry.new(content_entries: @content_entries, params: params, content_type: @content_type, site: current_site).entries_page_count
        respond_with page_count
      end

    end
  end
end