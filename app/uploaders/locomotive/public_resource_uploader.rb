module Locomotive
  class PublicResourceUploader < ::CarrierWave::Uploader::Base

    include Locomotive::CarrierWave::Uploader::Asset

    def store_dir
      self.build_store_dir('sites', model.site_id, 'public_resources', model.id)
    end

    def filename
      return if model.format_type != Locomotive::PublicResource::FormatTypes::FILE
      return original_filename unless model.name.present?
      "#{model.name.downcase.parameterize}.#{file.extension}"
    end

  end
end