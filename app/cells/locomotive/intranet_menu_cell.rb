module Locomotive
  class IntranetMenuCell < SubMenuCell

    protected

    def build_list
      add :users, url: users_path
      add :intranet_resources, url: intranet_resources_path
      # add :announcements, url: announcements_path
      # add :events, url: events_path
    end

  end
end
