class TaskJob < ApplicationJob
  before_perform do |job|
    task_for_job(job).start
  end

  around_perform do |job, perform_block|
    perform_block.call
    task_for_job(job).end_successfully
  end

  rescue_from(StandardError) do |exception|
    task_for_job(self).record_failure
    ExceptionNotifier.notify_exception(exception, data: {job: to_yaml})
    raise exception
  end

  private

  def task_for_job(job)
    Task.find(job.arguments.first[:task_id])
  end
end
