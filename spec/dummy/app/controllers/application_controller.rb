class ApplicationController < ActionController::Base
  protect_from_forgery

    def after_invite_path_for(resource_name)
      users_path
    end
end
