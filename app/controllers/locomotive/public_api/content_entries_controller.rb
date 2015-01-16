module Locomotive
  module PublicApi
    class ContentEntriesController < BaseController

      respond_to :json

      def index
        @content_type = current_site.content_types.where(slug: params[:slug]).first
        @content_entries = @content_type.entries.order_by([@content_type.order_by_definition])
        authenticate_portal_user if params[:calendar] == 'portal'
        @content_entries = Locomotive::Meritas::Api::ContentEntry.new(content_entries: @content_entries, user: current_portal_user, params: params, content_type: @content_type, site: current_site).entries
        respond_with @content_entries
      end

      def page_count
        @content_type = current_site.content_types.where(slug: params[:slug]).first
        @content_entries = @content_type.entries.order_by([@content_type.order_by_definition])
        page_count = Locomotive::Meritas::Api::ContentEntry.new(content_entries: @content_entries, params: params, content_type: @content_type, site: current_site).entries_page_count
        respond_to do |format|
          format.json { render json: @page_count.to_json }
        end
      end

      private

        def authenticate_portal_user
          authenticate_portal_user!
          return if current_site.has_user?(current_portal_user)
          sign_out(current_portal_user)
          return redirect_to '/portal/users/sign_in', error: "Please make sure the login credentials pertain to #{current_site.name}'s portal."
        end

    end
  end
end
