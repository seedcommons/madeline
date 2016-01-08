# encoding: utf-8

class MediaItemUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  IMAGE_REGEX = /\Aimage\/.*\z/i
  VIDEO_REGEX = /\Avideo\/.*\z/i

  # the kind of storage to use for this uploader
  storage :file

  process :set_content_type
  process :set_size_and_type_on_model
  process :set_media_kind_on_model
  process :set_height_and_width_on_model, if: :image?

  version :thumb, if: :image? do
    process resize_to_fill: [100, 100]
  end
  #TODO: Identify appropriate dimensions for these versions
  version :small
  version :medium
  version :large

  # the directory where uploaded files will be stored.
  def store_dir
    owner_type = model.media_attachable_type.underscore
    owner_id = model.media_attachable_id
    path = File.join('uploads', Rails.env, owner_type, "#{owner_id}", "#{model.id}")
    path
  end

  protected
  def image?(new_file)
    new_file.content_type =~ IMAGE_REGEX
  end

  def video?(new_file)
    new_file.content_type =~ VIDEO_REGEX
  end

  def set_size_and_type_on_model
    model.item_content_type = file.content_type if file.content_type
    model.item_file_size = file.size
  end

  def set_media_kind_on_model
    case model.item_content_type
    when IMAGE_REGEX
      model.kind = 'image'
    when VIDEO_REGEX
      model.kind = 'video'
    else
      model.kind = 'file'
    end
  end

  def set_height_and_width_on_model
    if file && model
      model.item_width, model.item_height = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
  end

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
