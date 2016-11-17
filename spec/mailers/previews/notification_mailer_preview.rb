# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/new_log
  def new_log
    # NotificationMailer.new_log(ProjectLog.last)
    NotificationMailer.new_log(ProjectLog.find(2427))
  end

end
