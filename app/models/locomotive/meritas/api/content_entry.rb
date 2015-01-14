module Locomotive
  class Meritas::Api::ContentEntry

    attr_reader :params, :content_type, :site
    attr_accessor :content_entries, :unpaginated_entries

    MERITAS_CUSTOM_CONTENT_TYPES = %w(events)

    def initialize(args = {})
      @content_entries = args[:content_entries]
      @params = args[:params]
      @user = args[:user]
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
        filter_by_function if params[:function_id].present?
        filter_by_group if params[:group_id].present?
        filter_by_grade if params[:grade_id].present?
        filter_by_publish_to if params[:calendar].present?
        filter_by_user if params[:calendar] == 'portal' && @user
        filter_by_date
        sort_entries
        filter_by_page if params[:page].present?
        @content_entries
      end

      def filter_by_date
        @non_recurring_events = @content_entries.dup
        filter_by_end_date if params[:end_date].present?
        filter_out_recurring_events
        filter_by_start_date if params[:start_date].present?
        filter_by_future_only if params[:future_only].present?
        incorporate_recurring_events
      end

      # RECURRING EVENTS
      def filter_out_recurring_events
        @non_recurring_events = @non_recurring_events.where(recurring: false)
      end

      def incorporate_recurring_events
        @content_entries = (@non_recurring_events << recurring_events).flatten
      end

      def recurring_events
        @recurring_events ||= Locomotive::Meritas::Api::RecurringEvents.new(params: params, events: @content_entries.where(recurring: true)).generate
      end

      def filter_by_end_date
        end_date = Date.parse(params[:end_date])
        @content_entries = @content_entries.where(:start_time.lte => end_date)
      end

      # DATE RANGE
      def filter_by_start_date
        start_date = Date.parse(params[:start_date])
        @non_recurring_events = @non_recurring_events.where(:end_time.gte => start_date)
      end

      # UPCOMING EVENTS ONLY
      def filter_by_future_only
        @non_recurring_events = @non_recurring_events.where(:end_time.gte => DateTime.now)
      end

      # GRADE
      def filter_by_grade
        @content_entries = @content_entries.or({grade: params[:grade_id], grade: nil})
      end

      def grade_content_type
        @group_content_type ||= @site.content_types.grades.first
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

      # USER
      def filter_by_user
        array = [@user.type, 'All']
        field = @content_type.entries_custom_fields.where(name: "user_type").first
        return unless field.present?
        ids = field.select_options.map {|f| array.include?(f.name) ? f._id : nil }.compact
        @content_entries = @content_entries.where(:user_type_id.in => ids)
      end

      def filter_by_publish_to
        calendar_hash = {
          "public" => ["Public Calendar", "All Calendars"],
          "portal" => ["Portal Calendar", "All Calendars"]
        }
        array = calendar_hash[params[:calendar]]
        field = @content_type.entries_custom_fields.where(name: "publish_to").first
        return unless field.present?
        ids = field.select_options.map {|f| array.include?(f.name) ? f._id : nil }.compact
        @content_entries = @content_entries.where(:publish_to_id.in => ids)
      end

      # SORT
      def sort_entries
        @content_entries.sort_by!(&:start_time)
      end


      # PAGE
      def page
        params[:page].to_i
      end

      def entries_to_skip
        page * @items_per_page.to_i
      end

      def end_of_range
        entries_to_skip + @items_per_page.to_i - 1
      end

      def entries_range
        entries_to_skip..end_of_range
      end

      def filter_by_page
        return @content_entries unless @content_entries.count > @items_per_page
        @content_entries = @content_entries[entries_range]
      end
  end
end
