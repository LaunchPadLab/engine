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

      before_filter :authenticate_intranet_user!, only: [:show], unless: :public_page?

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
        top_level_parent_page = locomotive_page.ancestors.last
        return true unless top_level_parent_page
        handle = top_level_parent_page.handle
        return true unless handle.present?
        return true if Locomotive::Page.whitelisted?(controller: controller_name, action: action_name)
        handle.downcase != "intranet"
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

    end
  end
end
