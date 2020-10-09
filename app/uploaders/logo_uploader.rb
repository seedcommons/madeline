class LogoUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  include CarrierWave::MiniMagick

  def store_dir
    File.join("uploads", Rails.env, model.class.to_s.underscore, "#{mounted_as}", "#{model.id}")
  end

  # Create different versions of your uploaded files:
  version :banner do
    process resize_to_fit: [840, 195]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
