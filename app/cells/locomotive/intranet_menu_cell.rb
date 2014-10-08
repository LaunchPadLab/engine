module Locomotive
  class IntranetMenuCell < SubMenuCell

    protected

    def build_list
      add :users, url: users_path
      add :invitations, url: new_invitation_path
      add :imports, url: new_import_path
    end

  end
end
