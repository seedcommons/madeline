class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.new_log.subject
  #

  def from_address(log)
    if log.agent.email.present?
      %Q("#{log.agent.name} <#{log.agent.email}>")
    else
      ApplicationMailer.default[:from]
    end
  end

  def new_log(log, user)
    @log = log
    mail(to: user.email,
         from: from_address(log) ,
         subject: I18n.t('notification_mailer.new_log.subject', project: log.project.display_name)
    )
  end
end
