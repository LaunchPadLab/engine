module Locomotive
  class InvitationsController < BaseController

    sections 'intranet'

    def new
      @invitation = current_site.invitations.new
    end

    def create
      @invitation = current_site.invitations.new(params[:invitation])
      @invitation.invited_by_id = current_locomotive_account.id

      if @invitation.save
        redirect_to users_path, notice: "The invitation was successfully sent."
      else
        render 'new'
      end
    end

  end
end
