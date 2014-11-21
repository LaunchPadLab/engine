module Locomotive
  class PortalMenuCell < SubMenuCell

    protected

    def build_list
      add :users, url: users_path
    end

  end
end
