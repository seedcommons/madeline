class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.new_log.subject
  #
  def new_log(log, user)
    @log = log
    mail to: user.email, subject: I18n.t('notification_mailer.new_log.subject', project: log.project.display_name)
  end
end
