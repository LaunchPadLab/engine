module Locomotive
  class PublicResourceUploader < ::CarrierWave::Uploader::Base

    include Locomotive::CarrierWave::Uploader::Asset

    def store_dir
      self.build_store_dir('sites', model.site_id, 'public_resources', model.id)
    end

  end
end