module Locomotive
  class User

    TYPES = ["Parent", "Faculty"]
    DUMMY_NAMES = ["Maxine Mercurio", "Robert Jones", "Joe Smith", "Ryan Francis", "Chris Courtney", "Alex Jeffries", "Jim Halpert", "Pam Beasley"]

    include Locomotive::Mongoid::Document

    devise :rememberable, :database_authenticatable, :recoverable, :trackable, :validatable, :encryptable

    ## devise fields (need to be declared since 2.x) ##
    field :remember_created_at,     type: Time
    field :email,                   type: String, default: ''
    field :encrypted_password,      type: String, default: ''
    field :authentication_token,    type: String
    field :reset_password_token,    type: String
    field :reset_password_sent_at,  type: Time
    field :password_salt,           type: String
    field :sign_in_count,           type: Integer, default: 0
    field :current_sign_in_at,      type: Time
    field :last_sign_in_at,         type: Time
    field :current_sign_in_ip,      type: String
    field :last_sign_in_ip,         type: String

    ## devise invitable
    field :invitation_token, type: String
    field :invitation_created_at, type: Time
    field :invitation_sent_at, type: Time
    field :invitation_accepted_at, type: Time
    field :invitation_limit, type: Integer

    # user fields
    field :type
    field :first_name
    field :last_name

    ## validations ##
    validates :first_name, :last_name, presence: true

    ## associations ##
    belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false

    ## indexes ##
    index({ email: 1 }, { unique: true, background: true })
    index site_id:    1

    # devise invitable
    index( {invitation_token: 1}, {:background => true} )
    index( {invitation_by_id: 1}, {:background => true} )

    def devise_mailer
      Locomotive::DeviseMailer
    end

    def full_name
      [first_name, last_name].compact.join(" ")
    end

    def self.build_dummies(site)
      users = DUMMY_NAMES.map do |name|
        names_array = name.split(" ")
        first_name = names_array.first
        last_name = names_array.last
        email = [first_name.downcase, "@example.com"].join("")
        site.users.new(email: email, first_name: first_name, last_name: last_name, type: TYPES.sample)
      end
      users
    end

  end
end
