module Locomotive
  module Public
    class PagesController < ApplicationController

      include Locomotive::Routing::SiteDispatcher
      include Locomotive::Render
      include Locomotive::ActionController::LocaleHelpers

      before_filter :require_site

      before_filter :authenticate_locomotive_account!, only: [:show_toolbar]

      before_filter :validate_site_membership, only: [:show_toolbar]

      before_filter :set_toolbar_locale, only: :show_toolbar

      before_filter :set_locale, only: [:show, :edit]

      before_filter :authenticate_portal_user, only: [:show], unless: :public_page?

      before_filter :redirect_to_calendar, only: [:show], if: :links_to_calendar?

      helper Locomotive::BaseHelper

      def show_toolbar
        render layout: false
      end

      def show
        render_locomotive_page
      end

      def edit
        @editing = true
        render_locomotive_page
      end

      protected

      def public_page?
        page = locomotive_page
        return true unless page
        page.does_not_belong_to_portal?
      end

      def links_to_calendar?
        locomotive_page.links_to_calendar?
      end

      def redirect_to_calendar
        return redirect_to locomotive_page.calendar_path
      end

      def set_toolbar_locale
        ::I18n.locale = current_locomotive_account.locale rescue Locomotive.config.default_locale
        ::Mongoid::Fields::I18n.locale = params[:locale] || current_site.default_locale
      end

      def set_locale
        ::Mongoid::Fields::I18n.locale = params[:locale] || current_site.default_locale
        ::I18n.locale = ::Mongoid::Fields::I18n.locale

        self.setup_i18n_fallbacks
      end

      def authenticate_portal_user
        authenticate_portal_user!
        return if current_site.has_user?(current_portal_user)
        sign_out(current_portal_user)
        return redirect_to '/portal/users/sign_in', error: "Please make sure the login credentials pertain to #{current_site.name}'s portal."
      end

    end
  end
end
