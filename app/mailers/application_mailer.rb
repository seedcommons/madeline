class ApplicationMailer < ActionMailer::Base
  default from: "Madeline System <#{ENV.fetch('MADELINE_EMAIL_FROM')}>"
  layout 'mailer'
end
