module Locomotive
  module Liquid
    module Drops
      class Site < Base

        delegate :name, :seo_title, :meta_keywords, :meta_description, to: :@_source

        def index
          @index ||= @_source.pages.root.first
        end

        def pages
          liquify(*self.scoped_pages)
        end

        def domains
          @_source.domains
        end

        def functions
          @functions ||= @_source.functions
        end

        def has_all_school_function?
          functions.detect {|f| f.name.downcase == "all school"}.present?
        end

        def grades
          @grades ||= @_source.grades
        end

        def has_all_school_grade?
          grades.detect {|g| g.name.downcase == "all school"}.present?
        end

        protected

        def scoped_pages
          if @context['with_scope']
            @_source.pages.where(@context['with_scope'])
          else
            @_source.pages
          end
        end

      end
    end
  end
end
