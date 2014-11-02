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

      end
    end
  end
end
