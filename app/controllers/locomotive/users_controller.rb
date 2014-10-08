module Locomotive
  class UsersController < BaseController

    sections 'intranet'

    def index
      @users = Locomotive::User.build_dummies(current_site)
    end

    def new
      @user = current_site.users.build
    end

    def create
      @invitation = Invitation.new

      @user = Locomotive::User.new(params[:user])
      raise @user.inspect
    end

    def confirm
      raise "hello"
      token = params[:token]
      invitation = Locomotive::Invitation.where(token: token).first
      invitation.accepted = true
      site = invitation.site
      @user = site.users.new(invitation.user_hash)
      raise @user.inspect
    end
  end
end
