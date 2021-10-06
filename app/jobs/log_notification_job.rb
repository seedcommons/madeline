class LogNotificationJob < ApplicationJob
  def perform(log)
    division = log.division
    return unless division.notify_on_new_logs?

    division.users.each do |user|
      NotificationMailer.new_log(log, user).deliver_now
    end
  end
end
