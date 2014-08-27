module Locomotive
  class Preview
    include Locomotive::Mongoid::Document

    REJECT_TEXT = "Reject Changes"

    ## fields ##
    field :params

    belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false
    belongs_to :page, class_name: 'Locomotive::Page', validate: true, autosave: false
    belongs_to :account, class_name: 'Locomotive::Account', validate: true, autosave: false

    # belongs_to  :account, class_name: 'Locomotive::Account', validate: false
    # validates_presence_of :account

  end
end
