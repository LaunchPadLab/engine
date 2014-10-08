module Locomotive
  class Invitation

    include Locomotive::Mongoid::Document

    field :first_name
    field :last_name
    field :type
    field :email
    field :token
    field :site_id
    field :invited_by_id
    field :accepted, type: Boolean, default: false

    ## indexes ##
    index({ email: 1 }, { unique: true, background: true })
    index site_id: 1
    index token: 1

    # associations
    belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false

    ## validations ##
    validates :first_name, :last_name, :email, presence: true

    # callbacks
    before_create :generate_token
    after_create  :send_invitation

    def full_name
      [first_name, last_name].compact.join(" ")
    end

    def status
      accepted? ? "Accepted" : "Pending"
    end

    def user_hash
      {first_name: first_name, last_name: last_name, type: type, email: email}
    end

    private

      def generate_token
        self.token = SecureRandom.urlsafe_base64
      end

      def send_invitation
        IntranetMailer.invitation(self).deliver
      end


  end
end
