module Locomotive
  class MainMenuCell < MenuCell

    protected

    def build_list
      add :contents,  url: pages_path,             icon: 'icon-folder-open' if can?(:manage, "Contents")
      add :settings,  url: edit_current_site_path, icon: 'icon-cog' if can?(:manage, "Settings")
      add :portal,    url: users_path,             icon: 'icon-cog' if can?(:manage, "Portal")
      add :lyris,     url: lyris_lists_path,        icon: 'icon-cog' if can?(:manage, "Lyris")
    end

  end
end
