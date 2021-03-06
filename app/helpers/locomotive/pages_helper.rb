module Locomotive
  module PagesHelper

    def extendable_pages_options
      hash = {}
      current_site.extendable_pages.each do |page|
        hash[page.title] = page.slug
      end
      hash["Parent"] = "parent"
      hash
    end

    def functions_for_select
      @function_content_type ||= current_site.content_types.functions.first
      hash = {}
      return hash unless @function_content_type.present?
      @function_content_type.entries.each {|e| hash[e.name] = e._id }
      return hash
    end

    def groups_for_select
      @group_content_type ||= current_site.content_types.groups.first
      hash = {}
      return hash unless @group_content_type.present?
      @group_content_type.entries.each {|e| hash["#{e.function.try(:name)} / #{e.name}"] = e._id }
      return hash
    end

    def grades_for_select
      @grade_content_type ||= current_site.content_types.grades.first
      hash = {}
      return hash unless @grade_content_type.present?
      @grade_content_type.entries.each {|e| hash[e.name] = e._id }
      return hash
    end

    def departments_for_select
      @department_content_type ||= current_site.content_types.departments.first
      hash = {}
      return hash unless @department_content_type.present?
      @department_content_type.entries.each {|e| hash[e.name] = e._id }
      return hash
    end

    def subdepartments_for_select
      @subdepartment_content_type ||= current_site.content_types.subdepartments.first
      hash = {}
      return hash unless @subdepartment_content_type.present?
      @subdepartment_content_type.entries.each {|e| hash[e.name] = e._id }
      return hash
    end

    def css_for_page(page)
      classes = %w(index not_found templatized redirect unpublished).inject([]) do |memo, state|
        memo << state.dasherize if page.send(:"#{state}?")
        memo
      end
      return classes.join(" ")
    end

    def page_toggler(page)
      icon_class = cookies["folder-#{page._id}"] != 'none' ? 'icon-caret-down' : 'icon-caret-right'
      content_tag :i, '',
        class:  "#{icon_class} toggler",
        data:   {
          open:   'icon-caret-down',
          closed: 'icon-caret-right'
        }
    end

    def parent_pages_options
      [].tap do |list|
        root = Locomotive::Page.quick_tree(current_site).first

        add_children_to_options(root, list)
      end
    end

    def add_children_to_options(page, list)
      return list if page.parent_ids.include?(@page.id) || page == @page

      offset = '- ' * (page.depth || 0) * 2

      list << ["#{offset}#{page.title}", page.id]
      page.children.each { |child| add_children_to_options(child, list) }
      list
    end

    def options_for_target_klass_name
      base_models = current_site.content_types.map do |type|
        [type.name.humanize, type.klass_with_custom_fields(:entries)]
      end
      base_models + Locomotive.config.models_for_templatization.map { |name| [name.underscore.humanize, name] }
    end

    def options_for_custom_form
      base_models = current_site.content_types.custom_forms.map do |type|
        [type.name.humanize, type.klass_with_custom_fields(:entries)]
      end
      base_models + Locomotive.config.models_for_templatization.map { |name| [name.underscore.humanize, name] }
    end

    def options_for_page_cache_strategy
      [
        [t('.cache_strategy.none'), 'none'],
        [t('.cache_strategy.simple'), 'simple'],
        [t('.cache_strategy.hour'), 1.hour.to_s],
        [t('.cache_strategy.day'), 1.day.to_s],
        [t('.cache_strategy.week'), 1.week.to_s],
        [t('.cache_strategy.month'), 1.month.to_s]
      ]
    end

    def options_for_page_response_type
      [
        ['HTML', 'text/html'],
        ['RSS', 'application/rss+xml'],
        ['XML', 'text/xml'],
        ['JSON', 'application/json']
      ]
    end

    def options_for_page_redirect_type
      [
        [t('.redirect_type.permanent'), 301],
        [t('.redirect_type.temporary'), 302]
      ]
    end

    def page_response_type_to_string(page)
      options_for_page_response_type.detect { |t| t.last == page.response_type }.try(:first) || '&mdash;'
    end

    # Give the path to the template of the page for the main locale ONLY IF
    # the user does not already edit the page in the main locale.
    #
    # @param [ Object ] page The page
    #
    # @return [ String ] The path or nil if the main locale is enabled
    #
    def page_main_template_path(page)
      if not_the_default_current_locale?
        page_path(page, content_locale: current_site.default_locale, format: :json)
      else
        nil
      end
    end

  end
end