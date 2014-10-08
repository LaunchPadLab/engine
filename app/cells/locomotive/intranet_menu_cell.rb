module Locomotive
  class IntranetMenuCell < SubMenuCell

    protected

    def build_list
      add :users, url: users_path
      add :new_invitation, url: new_invitation_path
      add :import, url: '#'
    end

  end
end
