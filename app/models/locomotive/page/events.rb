module Locomotive
  class Page::Events

    attr_accessor :page, :site, :event_entries, :content_type

    EVENTS_PER_WIDGET = 3

    def initialize(args = {})
      @page = args[:page]
      @site = @page.site
      @content_type = site.content_types.events.first
      @event_entries = []
    end

    def events
      Meritas::Api::ContentEntry.new(content_type: content_type, site: site, params: params, content_entries: unfiltered_events).entries
    end

      private

        def params
          {
            function_id: page.function_id,
            group_id: page.group_id,
            grade_id: page.grade_id,
            grade_logic_operator: Meritas::Api::ContentEntry::LogicOperators::INCLUSIVE,
            items_per_page: EVENTS_PER_WIDGET,
            future_only: true,
            calendar: @page.belongs_to_portal? ? "portal" : "public",
            page: 0
          }
        end

        def unfiltered_events
          content_type.entries.order_by([content_type.order_by_definition])
        end

  end
end