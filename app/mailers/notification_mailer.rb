class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.new_log.subject
  #
  def new_log
    mail to: 'adam@theworkingworld.org'
  end
end
