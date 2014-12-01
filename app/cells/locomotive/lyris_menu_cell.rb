module Locomotive
  class LyrisMenuCell < SubMenuCell

    protected

    def build_list
      add :lists, url: lyris_lists_path
      # add :announcements, url: announcements_path
      # add :events, url: events_path
      # add :resources, url: resources_path
    end

  end
end
