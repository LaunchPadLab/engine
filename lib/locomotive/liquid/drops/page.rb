module Locomotive
  module Liquid
    module Drops
      class Page < Base

        delegate :seo_title, :meta_keywords, :meta_description, :redirect_url, :handle, to: :@_source

        def title
          @_source.templatized? ? @context['entry']._label : @_source.title
        end

        def slug
          @_source.templatized? ? @context['entry']._slug.singularize : @_source.slug
        end

        def parent
          @parent ||= @_source.parent.to_liquid
        end

        def breadcrumbs
          @breadcrumbs ||= liquify(*@_source.ancestors_and_self)
        end

        def children
          @children ||= liquify(*@_source.children)
        end

        def fullpath
          @fullpath ||= @_source.fullpath
        end

        def depth
          @_source.depth
        end

        def listed?
          @_source.listed?
        end

        def published?
          @_source.published?
        end

        def redirect?
          @_source.redirect?
        end

        def templatized?
          @_source.templatized?
        end

        def calendar_url
          @_source.calendar_path
        end

        def content_type
          if @_source.content_type
            ContentTypeProxyCollection.new(@_source.content_type)
          else
            nil
          end
        end

        def before_method(meth)
          @_source.editable_elements.where(slug: meth).try(:first).try(:content)
        end

        def widget_1_album_photos
          album = @_source.widget_1_album
          return [] unless album.present?
          album.content_assets
        end

        def widget_2_album_photos
          album = @_source.widget_2_album
          return [] unless album.present?
          album.content_assets
        end

        def widget_3_album_photos
          album = @_source.widget_3_album
          return [] unless album.present?
          album.content_assets
        end

        def no_index
          @_source.no_index
        end

        def no_follow
          @_source.no_follow
        end

        def group
          @_source.group
        end

        def events
          @_source.events
        end

        def custom_form
          @custom_form ||= @_source.custom_form
        end

        def custom_form_content_type
          @custom_form_content_type ||= @_source.custom_form_content_type
        end

        def custom_form_url
          @custom_form_url ||= @context.registers[:controller].main_app.locomotive_entry_submissions_path(custom_form_content_type.slug)
        end

        def has_custom_form?
          custom_form.present?
        end

        def show_staff_directory
          @_source.show_staff_directory
        end

        def department_id
          @_source.department_id
        end

        def subdepartment_id
          @_source.subdepartment_id
        end

        def grade_id
          @_source.grade_id
        end

      end
    end
  end
end
