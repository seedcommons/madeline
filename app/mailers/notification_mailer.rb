class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.new_log.subject
  #

  def reply_to_address(log)
    # added check because some of the agents don't have emails
    if log.agent.email.present?
      "#{log.agent.name} <#{log.agent.email}>"
    else
      ApplicationMailer.default[:from]
    end
  end

  def new_log(log, user)
    @log = log
    mail(to: user.email,
         reply_to: reply_to_address(log),
         subject: I18n.t('notification_mailer.new_log.subject', project: log.project.display_name)
    )
  end
end
