module Locomotive
  class Meritas::Api::ContentEntry

    attr_reader :params, :content_type, :site
    attr_accessor :content_entries, :unpaginated_entries

    MERITAS_CUSTOM_CONTENT_TYPES = %w(events)

    def initialize(args = {})
      @content_entries = args[:content_entries]
      @params = args[:params]
      @content_type = args[:content_type]
      @site = args[:site]
      @items_per_page = (params[:items_per_page] || 6).to_f
    end

    def entries
      return @content_entries unless MERITAS_CUSTOM_CONTENT_TYPES.include?(slug)
      send("#{slug}_entries")
    end

    def entries_page_count
      events_entries
      (@content_entries.count / @items_per_page).ceil
    end

    private

      def slug
        @content_type.slug.downcase
      end

      def events_entries
        filter_by_start_date if params[:start_date].present?
        filter_by_end_date if params[:end_date].present?
        filter_by_function if params[:function_id].present?
        filter_by_group if params[:group_id].present?
        filter_by_subgroup if params[:subgroup_id].present?
        filter_by_publish_to if params[:calendar].present?
        filter_by_page if params[:page].present?
        @content_entries
      end

      # DATE RANGE
      def filter_by_start_date
        start_date = Date.parse(params[:start_date])
        @content_entries = @content_entries.where(:start_time.gte => start_date)
      end

      def filter_by_end_date
        end_date = Date.parse(params[:end_date])
        @content_entries = @content_entries.where(:end_time.lte => end_date)
      end

      # SUBGROUP
      def filter_by_subgroup
        @content_entries = @content_entries.where(subgroup: params[:subgroup_id])
      end

      def subgroup_content_type
        @group_content_type ||= @site.content_types.subgroups.first
      end

      # GROUP
      def filter_by_group
        @content_entries = @content_entries.where(group: params[:group_id])
      end

      def group_content_type
        @group_content_type ||= @site.content_types.groups.first
      end

      # FUNCTION
      def filter_by_function
        @content_entries = @content_entries.where(function: params[:function_id])
      end

      def function_content_type
        @function_content_type ||= @site.content_types.functions.first
      end

      #FUNCTION
      def filter_by_publish_to
        calendar_hash = {"public" => ["Public Calendar", "All Calendars"], "portal" => ["Portal Calendar", "All Calendars"]}
        array = calendar_hash[params[:calendar]]
        field = @content_type.entries_custom_fields.where(name: "publish_to").first
        return unless field.present?
        ids = field.select_options.map {|f| array.include?(f.name) ? f._id : nil }.compact
        @content_entries = @content_entries.where(:publish_to_id.in => ids)
      end

      # PAGE
      def filter_by_page
        page = params[:page].to_i
        @content_entries = @content_entries.skip(page*@items_per_page).limit(@items_per_page)
      end
  end
end
