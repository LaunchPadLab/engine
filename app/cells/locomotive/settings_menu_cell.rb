module Locomotive
  class SettingsMenuCell < SubMenuCell

    protected

    def build_list
      add :site,                  url: edit_current_site_path if can?(:manage, Site)
      add :theme_assets,          url: theme_assets_path if can?(:manage, ThemeAsset)
      add :translations,          url: translations_path if can?(:manage, Translation)
      add :account,               url: edit_my_account_path
      add :approvals,             url: previews_pages_path if can?(:manage, Page)
      add :import_events,         url: new_import_event_path if can?(:edit, Page)
    end

  end
end
