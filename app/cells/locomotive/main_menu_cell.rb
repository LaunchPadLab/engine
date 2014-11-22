module Locomotive
  class MainMenuCell < MenuCell

    protected

    def build_list
      add :contents,  url: pages_path,             icon: 'icon-folder-open'
      add :settings,  url: edit_current_site_path, icon: 'icon-cog'
      add :intranet,  url: users_path,             icon: 'icon-cog'
      add :lyris,     url: lyris_lists_path,        icon: 'icon-cog'
    end

  end
end
