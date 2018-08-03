# encoding: utf-8

class MediaItemUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  IMAGE_REGEX = %r{\Aimage\/.*\z}i

  # the kind of storage to use for this uploader
  storage :file

  process :set_size_and_type_on_model
  process :set_height_and_width_on_model, if: :image?

  version :thumb, if: :image? do
    process resize_to_fill: [100, 100]
    process convert: 'png'
  end
  #TODO: Identify appropriate dimensions for these versions
  version :small
  version :medium
  version :large

  # the directory where uploaded files will be stored.
  def store_dir
    owner_type = model.media_attachable_type.underscore
    owner_id = model.media_attachable_id
    File.join("uploads", Rails.env, owner_type, "#{owner_id}", "#{model.id}")
  end

  protected

  def image?(new_file)
    new_file.content_type =~ IMAGE_REGEX
  end

  def set_size_and_type_on_model
    model.item_content_type = file.content_type if file.content_type
    model.item_file_size = file.size
  end

  def set_height_and_width_on_model
    if file && model
      model.item_width, model.item_height = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
  end
end
