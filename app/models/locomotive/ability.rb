module Locomotive
  class Ability
    include CanCan::Ability

    GLOBAL_ADMIN = "admin"
    DEFAULT_ROLE = "beginner_user"
    REQUIRE_PAGE_PERMISSION = ["beginner_user", "advanced_user"]

    ROLES = %w(admin site_admin advanced_user beginner_user)

    def initialize(account, site)
      @account, @site = account, site

      alias_action :index, :show, :edit, :update, to: :touch
      if @site
        @membership = @site.memberships.where(account_id: @account.id).first
      elsif @account.admin?
        @membership = Membership.new(account: @account, role: 'admin')
      end

      if @membership.nil?
        setup_account_without_a_site
      else
        setup_default_permissions!
        send("setup_#{@membership.role}_permissions!")
      end
    end

    def setup_account_without_a_site
      cannot :manage, :all

      can :create, Site
    end

    def setup_default_permissions!
      cannot :manage, :all
    end

    def setup_beginner_user_permissions!
      can :touch, ThemeAsset

      can :manage, Preview

      cannot :manage, Page

      can [:edit, :read], Page do |page|
        @membership.pages.include?(page.id.to_s)
      end

      can :manage, [ContentEntry, ContentAsset, Translation]

      can :touch, Site, _id: @site._id

      can :read, ContentType
    end

    def setup_advanced_user_permissions!
      cannot :manage, Page
      can :touch, ThemeAsset

      can [:edit, :read, :customize, :update], Page do |page|
        @membership.pages.include?(page.id.to_s)
      end
      cannot :destroy, Page

      can :manage, [ContentEntry, ContentAsset, Translation]

      can :touch, Site, _id: @site._id

      can :read, ContentType
    end

    def setup_site_admin_permissions!
      can :manage, Page

      can :manage, Preview

      can :manage, ContentEntry

      can :manage, ContentType

      can :manage, Snippet

      can :manage, ThemeAsset

      can :manage, ContentAsset

      can :manage, Translation

      can :manage, Site, _id: @site._id

      can :point, Site

      cannot :create, Site

      can :manage, Membership

      cannot :grant_admin, Membership

      cannot [:update, :destroy], Membership do |membership|
        @membership.account_id == membership.account_id || # can not edit myself
        membership.admin? # can not modify an administrator
      end
    end

    def setup_admin_permissions!
      can :manage, :all

      cannot [:update, :destroy], Membership do |membership|
        @membership.account_id == membership.account_id # can not edit myself
      end
    end
  end
end
