module Locomotive
  class SitesController < BaseController

    sections 'settings'

    respond_to :json, only: [:create, :destroy]

    def new
      @site = Site.new
      respond_with @site
    end

    def create
      @site = Site.new(params[:site])
      current_site.memberships.where(role: Locomotive::Ability::GLOBAL_ADMIN).each do |m|
        @site.memberships.build account: m.account, role: Locomotive::Ability::GLOBAL_ADMIN
      end
      @site.save
      respond_with @site, location: edit_my_account_path
    end

    def destroy
      @site = self.current_locomotive_account.sites.find(params[:id])

      if @site != current_site
        @site.destroy
      else
        @site.errors.add(:base, 'Can not destroy the site you are logging in now')
      end

      respond_with @site, location: edit_my_account_path
    end

  end
end
