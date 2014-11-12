module Locomotive
  class Meritas::Api::ContentEntry

    attr_reader :params, :content_type, :site
    attr_accessor :content_entries

    MERITAS_CUSTOM_CONTENT_TYPES = ["event"]

    def initialize(args = {})
      @content_entries = args[:content_entries]
      @params = args[:params]
      @content_type = args[:content_type]
      @site = args[:site]
    end

    def entries
      return @content_entries unless MERITAS_CUSTOM_CONTENT_TYPES.include?(slug)
      send("#{slug}_entries")
    end

    private

      def slug
        @content_type.slug.downcase
      end

      def event_entries
        filter_by_date_range if start_date.present? && end_date.present?
        filter_by_function if params[:function_id].present?
        filter_by_group if params[:group_id].present?
        return @content_entries
      end

      def start_date
        @start_date ||= params[:start_date]
      end

      def end_date
        @end_date ||= params[:start_date]
      end

      def filter_by_date_range
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        @content_entries = @content_entries.where(:start_time.gte => start_date, :end_time.lte => end_date)
      end

      # GROUP
      def filter_by_group
        @content_entries = @content_entries.where(group: group_entry)
      end

      def group_content_type
        @group_content_type ||= @site.content_types.where(slug: "group").first
      end

      def group_entry
        group_content_type.entries.find(params[:group_id])
      end

      # FUNCTION
      def filter_by_function
        group_ids = group_content_type.entries.where(function: function_entry).map(&:_id)
        @content_entries = @content_entries.where(:group_id.in => group_ids)
      end

      def function_content_type
        @function_content_type ||= @site.content_types.where(slug: "function").first
      end

      def function_entry
        function_content_type.entries.find(params[:function_id])
      end

  end
end