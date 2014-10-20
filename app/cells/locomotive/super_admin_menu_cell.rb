module Locomotive
  class SuperAdminMenuCell < SubMenuCell

    protected

    def build_list
      add :shared_resources,  url: shared_resources_path
    end

  end
end
