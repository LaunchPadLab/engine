module Locomotive
  module Extensions
    module Page
      module Albums

        extend ActiveSupport::Concern

        included do
          belongs_to :widget_1_album, class_name: '::Ckeditor::Album', validate: false, autosave: false
          belongs_to :widget_2_album, class_name: '::Ckeditor::Album', validate: false, autosave: false
          belongs_to :widget_3_album, class_name: '::Ckeditor::Album', validate: false, autosave: false

          index widget_1_album_id:    1
          index widget_2_album_id:    1
          index widget_3_album_id:    1
        end

      end
    end
  end
end