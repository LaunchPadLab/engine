module Locomotive
  class MainMenuCell < MenuCell

    protected

    def build_list
      add :contents,      url: pages_path,             icon: 'icon-folder-open'
      add :settings,      url: edit_current_site_path, icon: 'icon-cog'
      add :super_admin,   url: shared_resources_path,  icon: 'icon-cog' if can?(:manage, SharedResource)
    end

  end
end
