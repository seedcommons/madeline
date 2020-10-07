CarrierWave.configure do |config|
  config.storage = (ENV['STORAGE_MODE'] == 'cloud') ? :fog : :file

  config.fog_credentials = {
    provider:              'AWS', # required
    aws_access_key_id:     ENV['STORAGE_ACCESS_KEY'], # required unless using use_iam_profile
    aws_secret_access_key: ENV['STORAGE_SECRET_KEY'], # required unless using use_iam_profile
    use_iam_profile:       false, # optional, defaults to false
    region:                ENV['STORAGE_REGION'], # optional, defaults to 'us-east-1'
    host:                  ENV['STORAGE_HOST'], # optional, defaults to nil
    endpoint:              ENV['STORAGE_ENDPOINT'] # optional, defaults to nil
  }
  config.fog_directory  = 'madeline-files' # required
  config.fog_public     = false # optional, defaults to true
  config.fog_attributes = {cache_control: "public, max-age=#{365.days.to_i}"} # optional, defaults to {}
end
