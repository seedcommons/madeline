# encoding: utf-8

class DataExportAttachmentUploader < CarrierWave::Uploader::Base

  # the kind of storage to use for this uploader
  storage :file

  #process :set_size_and_type_on_model

  # the directory where uploaded files will be stored.
  def store_dir
    File.join("exports/", Rails.env, "#{model.id}")
  end

  protected


# def set_size_and_type_on_model
#     model.item_content_type = file.content_type if file.content_type
#     model.item_file_size = file.size
#   end



  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Add a whitelist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
