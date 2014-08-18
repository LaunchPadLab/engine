module Locomotive
  class Preview
    include Locomotive::Mongoid::Document

    ## fields ##
    field :page_id
    field :params

    belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false

    # belongs_to  :account, class_name: 'Locomotive::Account', validate: false
    # validates_presence_of :account
  end
end
