module Locomotive
  class Site

    include Locomotive::Mongoid::Document

    ## Extensions ##
    extend  Extensions::Site::SubdomainDomains
    extend  Extensions::Site::FirstInstallation
    include Extensions::Shared::Seo
    include Extensions::Site::Locales
    include Extensions::Site::Timezone
    include Extensions::Site::Mailer

    ## fields ##
    field :name
    field :portal_name, default: "Portal"
    field :robots_txt

    ## associations ##

    has_many    :pages,                   class_name: 'Locomotive::Page',               validate: false, autosave: false
    has_many    :snippets,                class_name: 'Locomotive::Snippet',            dependent: :destroy, validate: false, autosave: false
    has_many    :theme_assets,            class_name: 'Locomotive::ThemeAsset',         dependent: :destroy, validate: false, autosave: false
    has_many    :content_assets,          class_name: 'Locomotive::ContentAsset',       dependent: :destroy, validate: false, autosave: false
    has_many    :content_types,           class_name: 'Locomotive::ContentType',        dependent: :destroy, validate: false, autosave: false
    has_many    :content_entries,         class_name: 'Locomotive::ContentEntry',       dependent: :destroy, validate: false, autosave: false
    has_many    :calendar_feeds,          class_name: 'Locomotive::CalendarFeed',       dependent: :destroy, validate: false, autosave: false
    has_many    :translations,            class_name: 'Locomotive::Translation',        dependent: :destroy, validate: false, autosave: false
    embeds_many :memberships,             class_name: 'Locomotive::Membership'

    has_many    :users,                   class_name: 'Locomotive::User',               validate: false, autosave: false
    has_many    :invitations,             class_name: 'Locomotive::Invitation',         validate: false, autosave: false
    has_many    :public_resources,        class_name: 'Locomotive::PublicResource',     validate: false, autosave: false
    has_many    :folders,                 class_name: 'Ckeditor::Folder',               validate: false, autosave: false
    has_many    :albums,                  class_name: 'Ckeditor::Album',                validate: false, autosave: false
    has_many    :previews,                class_name: 'Locomotive::Preview',            validate: false, autosave: false

    ## validations ##
    validates_presence_of :name

    ## callbacks ##
    after_create    :create_default_pages!
    after_destroy   :destroy_pages

    ## behaviours ##
    enable_subdomain_n_domains_if_multi_sites
    accepts_nested_attributes_for :memberships, allow_destroy: true

    ## methods ##

    def all_users
      (Locomotive::User.where(is_super_admin: true) + Locomotive::User.where(site: self)).uniq
    end

    def custom_content_types
      [content_types.events.first] + content_types.custom_forms
    end

    def functions
      content_type = content_types.functions.first
      return [] unless content_type.present?
      content_type.entries
    end

    def grades
      content_type = content_types.grades.first
      return [] unless content_type.present?
      content_type.entries
    end

    def has_user?(user)
      return false if user.nil?
      all_users.detect { |u| u._id.to_s == user._id.to_s }.present?
    end

    def portal_home_id
      @portal_home_id ||= Page.portal_home(self).try(:_id).try(:to_s) || ''
    end

    def all_pages_in_once
      Page.quick_tree(self)
    end

    def fetch_page(path, logged_in)
      Locomotive::Page.fetch_page_from_path self, path, logged_in
    end

    def accounts
      Account.criteria.in(_id: self.memberships.map(&:account_id))
    end

    def admin_memberships
      self.memberships.find_all { |m| m.admin? }
    end

    def is_admin?(account)
      self.memberships.detect { |m| m.admin? && m.account_id == account._id }
    end

    def extendable_pages
      self.pages.where(extendable: true)
    end

    def site_admins
      memberships.where(:role.in => Locomotive::Ability::SITE_ADMIN_ROLES).includes(:account).map(&:account)
    end

    def super_admins
      memberships.where(:role => Locomotive::Ability::GLOBAL_ADMIN).includes(:account).map(&:account)
    end

    protected

    # FIXME: Currently there is no t/translate method on the I18n module
    # Extensions::Site::I18n which is breaking the testing. The
    # namespaced ::I18n should be changed to just I18n when the t()
    # method is available
    def create_default_pages!
      %w{index 404}.each do |slug|
        page = nil

        self.each_locale do |locale|
          page ||= self.pages.build(published: true) # first locale = default one

          page.attributes = {
            slug:         slug,
            title:        ::I18n.t("attributes.defaults.pages.#{slug}.title", locale: locale),
            raw_template: ::I18n.t("attributes.defaults.pages.#{slug}.body", locale: locale)
          }
        end

        self.with_default_locale { page.save! }
      end

    end

    def destroy_pages
      # pages is a tree so we just need to delete the root (as well as the page not found page)
      self.pages.root.first.try(:destroy) && self.pages.not_found.first.try(:destroy)
    end

  end
end
