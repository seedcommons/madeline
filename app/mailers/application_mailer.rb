class ApplicationMailer < ActionMailer::Base
  default from: %Q("Madeline System" <#{ENV.fetch('MADELINE_EMAIL_FROM')}>)
end
