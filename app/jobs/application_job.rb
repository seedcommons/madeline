class ApplicationJob < ActiveJob::Base
  queue_as :default

  rescue_from(StandardError) do |exception|
    ExceptionNotifier.notify_exception(exception, data: error_report_data)
  end

  protected

  def error_report_data
    nil
  end
end
