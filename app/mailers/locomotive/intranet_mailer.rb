module Locomotive
  class IntranetMailer < ActionMailer::Base

    def invitation(invitation)
      @invitation = invitation
      @site = invitation.site
      mail(subject: "You've Been Invited To #{@site.name}", to: invitation.email, from: 'support@example.com')
    end

  end
end
