# Send email on errors
unless Rails.env.test?
  Rails.application.config.middleware.use ExceptionNotification::Rack, email: {
    email_prefix: "[Madeline #{Rails.env.to_s.capitalize}] ",
    sender_address: %("Madeline" <#{ENV['MADELINE_EMAIL_FROM']}>),
    exception_recipients: [ENV["MADELINE_ERROR_EMAILS_TO"]]
  }
end
