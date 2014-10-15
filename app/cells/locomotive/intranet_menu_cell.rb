module Locomotive
  class IntranetMenuCell < SubMenuCell

    protected

    def build_list
      add :users, url: users_path
      add :announcements, url: announcements_path
      # add :events, url: events_path
      add :resources, url: resources_path
    end

  end
end
