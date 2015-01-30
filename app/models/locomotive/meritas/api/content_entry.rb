module Locomotive
  class Meritas::Api::ContentEntry

    attr_reader :params, :content_type, :site
    attr_accessor :content_entries, :unpaginated_entries, :functions, :grades, :groups, :default_filter_setting

    MERITAS_CUSTOM_CONTENT_TYPES = %w(events)

    module LogicOperators
      EXCLUSIVE = 'exclusive' # excludes entries tagged 'all'
      INCLUSIVE = 'inclusive' # includes entries tagged 'all'
    end

    module FilterOperators
      SELECTED = 'selected' # defaults to all filters are selected (i.e. included)
      UNSELECTED = 'unselected'# defaults to all filters unselected (i.e. excluded)
    end

    def initialize(args = {})
      @content_entries = args[:content_entries]
      @params = args[:params]
      @user = args[:user]
      @content_type = args[:content_type]
      @site = args[:site]
      @items_per_page = (params[:items_per_page] || 6).to_f
      @default_filter_setting = params.fetch(:default_filter_setting, FilterOperators::UNSELECTED)
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
        set_event_categories
        filter_by_functions if functions.present? || defaults_to_selected?
        filter_by_grades if grades.present? || defaults_to_selected?
        filter_by_groups if groups.present? || defaults_to_selected?
        filter_by_publish_to if params[:calendar].present?
        filter_by_user if params[:calendar] == 'portal' && @user
        filter_by_date
        filter_out_recurring_event_parents
        filter_by_page if params[:page].present?
        @content_entries
      end

      # set functions, grades, and groups to filter by
      def set_event_categories
        ["function", "grade", "group"].each do |type|
          singular = "#{type}_id" # function_id, grade_id, group_id
          plural = "#{type.pluralize}" # functions, grades, groups
          plural_ids = params[plural].present? ? JSON.parse(params[plural]) : []
          plural_ids.reject! {|id| id.blank? }
          if params[singular].present? || plural_ids.any?
            ids = params[singular].present? ? [params[singular]] : plural_ids
          else
            ids = []
          end
          instance_variable_set("@#{plural}", ids)
        end
      end

      def filter_by_date
        filter_by_end_date if params[:end_date].present?
        filter_by_start_date if params[:start_date].present?
        filter_by_future_only if params[:future_only].present?
      end

      def filter_out_recurring_event_parents
        # these are "parent" events (ghosts) that shouldn't appear on calendar
        # the purpose of the recurring event is to control the events that derive from it
        @content_entries = @content_entries.where(:recurring.in => [false, nil])
      end

      # DATE RANGE
      def filter_by_end_date
        end_date = Date.parse(params[:end_date])
        @content_entries = @content_entries.where(:start_time.lte => end_date)
      end

      def filter_by_start_date
        start_date = Date.parse(params[:start_date])
        @content_entries = @content_entries.where(:end_time.gte => start_date)
      end

      # UPCOMING EVENTS ONLY
      def filter_by_future_only
        @content_entries = @content_entries.where(:end_time.gte => DateTime.now)
      end

      # GRADE
      def filter_by_grades
        all_school = @site.content_types.grades.first.entries.where(name: "All School").first
        grades << nil # defaults to include events tagged with grade level of "All"
        grades << all_school if all_school # defaults to include events tagged with grade level of "All School"
        grades.compact! if params[:grade_logic_operator] && params[:grade_logic_operator] == LogicOperators::EXCLUSIVE
        @content_entries = @content_entries.where(:grade.in => grades)
      end

      def grade_content_type
        @group_content_type ||= @site.content_types.grades.first
      end

      # GROUP
      def filter_by_groups
        groups << nil
        @content_entries = @content_entries.where(:group.in => groups)
      end

      def group_content_type
        @group_content_type ||= @site.content_types.groups.first
      end

      # FUNCTION
      def filter_by_functions
        @content_entries = @content_entries.where(:function.in => functions)
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

      def filter_by_page
         page = params[:page].to_i
         @content_entries = @content_entries.skip(page*@items_per_page).limit(@items_per_page)
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

      def defaults_to_selected?
        default_filter_setting == FilterOperators::SELECTED
      end
  end
end
