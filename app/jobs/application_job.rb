class ApplicationJob < ActiveJob::Base
  queue_as :default

  rescue_from(StandardError) do |exception|
    ExceptionNotifier.notify_exception(exception, data: {job: to_yaml})
  end
end
