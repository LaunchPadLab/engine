module Locomotive
  module Liquid
    module Tags
      # Display the children pages of the site, current page or the parent page. If not precised, nav is applied on the current page.
      # The html output is based on the ul/li tags.
      #
      # Passing through depth will control how many nested children are output
      #
      # Usage:
      #
      # {% nav site %} => <ul class="nav"><li class="on"><a href="/features">Features</a></li></ul>
      #
      # {% nav site, no_wrapper: true, exclude: 'contact|about', id: 'main-nav', class: 'nav', active_class: 'on' }
      #
      class Nav < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @source = ($1 || 'page').gsub(/"|'/, '')
            @options = { id: 'nav', depth: 1, class: '', active_class: 'on', bootstrap: false }
            markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }

            @options[:exclude] = Regexp.new(@options[:exclude]) if @options[:exclude]

            @options[:add_attributes] = []
            if @options[:snippet]
              template = @options[:snippet].include?('{') ? @options[:snippet] : context[:site].snippets.where(slug: @options[:snippet] ).try(:first).try(:template)
              unless template.blank?
                @options[:liquid_render] = ::Liquid::Template.parse(template)
                @options[:add_attributes] = ['editable_elements']
              end
            end

          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'nav' - Valid syntax: nav <page|site> <options>")
          end

          super
        end

        def top_page_id
          @page.parent_ids[1].try(:to_s) || @page.id.to_s
        end

        def top_page_active?
          @page.id.to_s == top_page_id
        end

        def top_page
          @all_pages_by_id[top_page_id].first
        end

        def children(page)
          @parent_child_hash[page.id.to_s] || []
        end

        def has_active_child?(page)
          return false if children(page).blank?
          children(page).include?(@page) || children(page).map {|p| children(p) }.flatten.include?(@page)
        end

        def has_children?(page)
          children(page).any?
        end

        def render(context)
          children_output = []

          entries = fetch_entries(context)
          entries.each_with_index do |p, index|
            css = []
            css << 'first' if index == 0
            css << 'last' if index == entries.size - 1

            children_output << render_entry_link(context, p, css.join(' '), 1)
          end

          output = children_output.join("\n")

          if @options[:no_wrapper] != 'true'
            list_class  = !@options[:class].blank? ? %( class="#{@options[:class]}") : ''
            output      = %{<nav id="#{@options[:id]}"#{list_class}><ul>\n#{output}</ul></nav>}
          end
          output.prepend(%{<li class="parent #{'active' if top_page_active?}"><a href="/#{top_page.fullpath}">#{top_page.title}</a></li>}) if @source != 'site'

          output
        end

        private

        def set_parent_child_hash
          # { parent_id => [child_ids] }
          @parent_child_hash = {}
          @all_pages.each_with_index do |page, index|
            immediate_parent_id = page.parent_ids[-1].try(:to_s)
            if immediate_parent_id
              array = @parent_child_hash[immediate_parent_id] || []
              array << page
              @parent_child_hash[immediate_parent_id] = array
            end
          end
        end

        def set_defaults
          @all_pages = @site.pages
          @all_pages_by_id = @all_pages.group_by {|p| p.id.to_s }
          set_parent_child_hash
          css_classes = { active_class: 'active', has_children_class: 'has-children', has_active_child_class: 'has-active-child', has_dropdown_class: 'has-dropdown', depth_class: 'depth', dropdown_class: 'dropdown'}
          @options = @options.merge(css_classes)
        end

        # Determines root node for the list
        def fetch_entries(context)
          @site, @page = context.registers[:site], context.registers[:page]
          set_defaults

          page = (case @source
          when 'site'     then @all_pages.root.minimal_attributes(@options[:add_attributes]).first # start from home page
          when 'parent'   then top_page
          when 'page'     then @page
          else
            @all_pages.fullpath(@source).minimal_attributes(@options[:add_attributes]).first
          end)

          children = children(page)

          children.delete_if { |p| !include_page?(p) }
        end

        # Returns a list element, a link to the page and its children
        def render_entry_link(context, page, css, depth)
          selected = @page == page ? " #{@options[:active_class]}" : ''

          icon  = @options[:icon] ? '<span></span>' : ''
          title = render_title(context, page)
          label = %{#{icon if @options[:icon] != 'after' }#{title}#{icon if @options[:icon] == 'after' }}

          link_options = caret = ''
          href = File.join('/', @site.localized_page_fullpath(page))

          if render_children_for_page?(page, depth) && bootstrap?
            css           += ' dropdown'
            link_options  = %{ class="dropdown-toggle" data-toggle="dropdown"}
            href          = '#'
            caret         = %{ <b class="caret"></b>}
          end

          has_children_class = has_children?(page) ? @options[:has_children_class] : nil
          has_active_child_class = has_active_child?(page) ? @options[:has_active_child_class] : nil
          has_dropdown_class = page.depth == 1 && @source == 'site' ? @options[:has_dropdown_class] : nil
          css_classes_string = ["link#{selected}", "#{css}", "#{@options[:depth_class]}-#{page.depth}", has_children_class, has_active_child_class, has_dropdown_class].compact.join(" ")
          output  = %{<li id="#{page.slug.to_s.dasherize}-link" class="#{css_classes_string}">}
          output << %{<a href="#{href}"#{link_options}>#{label}#{caret}</a>}
          output << render_entry_children(context, page, depth.succ) if (depth.succ <= @options[:depth].to_i)
          output << %{</li>}

          output.strip
        end

        def render_children_for_page?(page, depth)
          depth.succ <= @options[:depth].to_i && children(page).reject { |c| !include_page?(c) }.any?
        end

        # Recursively creates a nested unordered list for the depth specified
        def render_entry_children(context, page, depth)
          output = %{}

          children = children(page).reject { |c| !include_page?(c) }
          if children.present?
            dropdown_class = @source == 'site' && page.depth == 1 ? @options[:dropdown_class] : ''
            output = %{<ul id="#{@options[:id]}-#{page.slug.to_s.dasherize}" class="#{bootstrap? ? 'dropdown-menu' : dropdown_class}">}
            children.each do |c, page|
              css = []
              css << 'first' if children.first == c
              css << 'last'  if children.last  == c

              output << render_entry_link(context, c, css.join(' '), depth)
            end
            output << %{</ul>}
          end

          output
        end

        def render_title(context, page)
          if @options[:liquid_render]
            context.stack do
              context['page'] = page
              @options[:liquid_render].render(context)
            end
          else
            page.title
          end
        end

        # Determines whether or not a page should be a part of the menu
        def include_page?(page)
          if !page.listed? || page.templatized? || !page.published?
            false
          elsif @options[:exclude]
            (page.fullpath =~ @options[:exclude]).nil?
          else
            true
          end
        end

        def bootstrap?
          @options[:bootstrap] == 'true'
        end

      end

      ::Liquid::Template.register_tag('nav', Nav)
    end
  end
end
