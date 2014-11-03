module Locomotive
  module Extensions
    module Page
      module Widgets

        extend ActiveSupport::Concern

        included do
          # album widget
          belongs_to :widget_1_album, class_name: '::Ckeditor::Album', validate: false, autosave: false
          belongs_to :widget_2_album, class_name: '::Ckeditor::Album', validate: false, autosave: false
          belongs_to :widget_3_album, class_name: '::Ckeditor::Album', validate: false, autosave: false

          index widget_1_album_id:    1
          index widget_2_album_id:    1
          index widget_3_album_id:    1

          # photo widget
          belongs_to :widget_1_photo, class_name: 'Locomotive::ContentAsset', validate: false, autosave: false
          belongs_to :widget_2_photo, class_name: 'Locomotive::ContentAsset', validate: false, autosave: false
          belongs_to :widget_3_photo, class_name: 'Locomotive::ContentAsset', validate: false, autosave: false

          index widget_1_photo_id:    1
          index widget_2_photo_id:    1
          index widget_3_photo_id:    1
        end

      end
    end
  end
end