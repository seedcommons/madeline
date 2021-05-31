class ApplicationJob < ActiveJob::Base
  queue_as :default

  rescue_from(StandardError) do |error|
    notify_of_error(error)

    # Re-raising the error so that the job system will detect it and act accordingly.
    raise error
  end

  protected

  def notify_of_error(error, data: {})
    ExceptionNotifier.notify_exception(error, data: data.merge(job: to_yaml))
  end
end
