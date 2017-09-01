class ApplicationJob < ActiveJob::Base
  queue_as :default

  # Note: rescue_from appears to immediately delete the job from the queue, so DelayedJob's retry
  # functionality will not work. If we need retries, consider using ActiveJob's retry_job method or
  # https://github.com/isaacseymour/activejob-retry.
  rescue_from(StandardError) do |exception|
    ExceptionNotifier.notify_exception(exception, data: {job: to_yaml})
  end
end
