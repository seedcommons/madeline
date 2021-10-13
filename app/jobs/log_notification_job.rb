class LogNotificationJob < ApplicationJob
  def perform(log)
    division = log.division
    return unless division.notify_on_new_logs?

    ancestors = division.ancestors.pluck(:id)
    base_scope = Person.with_system_access.joins(:user).where.not(users: {notification_source: "none"})
    own_division = base_scope.where(division: division)
    subdivision = base_scope.where(division: ancestors).where(users: {notification_source: "home_and_sub"})
    people = own_division.or(subdivision)

    people.each do |person|
      NotificationMailer.new_log(log, person.user).deliver_now
    end
  end
end
