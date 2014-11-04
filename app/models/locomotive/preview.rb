module Locomotive
  class Preview
    include Locomotive::Mongoid::Document

    REJECT_TEXT = "Reject Changes"

    module State
      TEMPORARY = "temporary"
      PENDING_APPROVAL = "pending_approval"
    end

    ## fields ##
    field :params
    field :state, default: State::TEMPORARY

    embeds_many :editable_elements, class_name: 'Locomotive::EditableElement'
    accepts_nested_attributes_for :editable_elements
    belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false
    belongs_to :page, class_name: 'Locomotive::Page', validate: true, autosave: false
    belongs_to :account, class_name: 'Locomotive::Account', validate: true, autosave: false

    # belongs_to  :account, class_name: 'Locomotive::Account', validate: false
    # validates_presence_of :account

    scope :active, -> { where(state: State::PENDING_APPROVAL) }

    def set_to_pending_approval
      self.state = State::PENDING_APPROVAL
    end

    def submit_for_approval!
      set_to_pending_approval
      self.save
    end

    def create_editable_elements(args = {})
      page_params, page = args[:page_params], args[:page]
      page_params[:editable_elements_attributes].each do |key,params_hash|
        el = Locomotive::EditableFile.new({preview: self, from_parent: true, from_preview_slug: page.slug, page: page}.merge(params_hash))
        el.save(validate: false)
      end
    end

  end
end
