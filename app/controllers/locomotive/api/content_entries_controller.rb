module Locomotive
  module Api
    class ContentEntriesController < BaseController

      load_and_authorize_resource({
        class:                Locomotive::ContentEntry,
        through:              :get_content_type,
        through_association:  :entries,
        find_by:              :find_by_id_or_permalink
      })

      def index
        @content_entries = @content_entries.order_by([get_content_type.order_by_definition])

        if params[:start_date] && params[:end_date]
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          @content_entries = @content_entries.where(:start_time.gte => start_date, :end_time.lte => end_date)
        end

        if params[:function_id].present?
          function_entry = function_content_type.entries.find(params[:function_id])
          group_ids = group_content_type.entries.where(function: function_entry).map(&:_id)
          @content_entries = @content_entries.where(:group_id.in => group_ids)
        end

        if params[:group_id].present?
          group_entry = group_content_type.entries.find(params[:group_id])
          @content_entries = @content_entries.where(group: group_entry)
        end

        respond_with @content_entries
      end

      def show
        respond_with @content_entry, status: @content_entry ? :ok : :not_found
      end

      def create
        @content_entry.from_presenter(params[:content_entry] || params[:entry])
        @content_entry.save
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      def update
        @content_entry.from_presenter(params[:content_entry] || params[:entry])
        @content_entry.save
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      def destroy
        @content_entry.destroy
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      protected

      def get_content_type
        @content_type ||= current_site.content_types.where(slug: params[:slug]).first
      end

      def group_content_type
        @group_content_type ||= current_site.content_types.where(slug: "group").first
      end

      def function_content_type
        @function_content_type ||= current_site.content_types.where(slug: "function").first
      end
    end
  end
end
