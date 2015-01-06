module Locomotive
  module Liquid
    module Drops
      class CurrentPortalUser < Base

        def logged_in?
          @_source.present?
        end

        def first_name
          @_source.first_name if logged_in?
        end

        def email
          @_source.email if logged_in?
        end

        def type
          @_source.type if logged_in?
        end

        def parent?
          @_source.parent? if logged_in?
        end

        def faculty?
          @_source.faculty? if logged_in?
        end

        def student?
          @_source.student? if logged_in?
        end

        def alumnus?
          @_source.alumnus? if logged_in?
        end

        def boarding?
          @_source.boarding? if logged_in?
        end
      end
    end
  end
end
