module Locomotive
  class IntranetResourceUploader < ::CarrierWave::Uploader::Base

    include Locomotive::CarrierWave::Uploader::Asset

    def store_dir
      self.build_store_dir('sites', model.site_id, 'intranet_resources', model.id)
    end

  end
end