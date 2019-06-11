class TaskJob < ApplicationJob
  around_perform do |job, perform_block|
    task_for_job(job).start!
    perform_block.call
    task_for_job(job).finish!
  end

  rescue_from(StandardError) do |exception|
    task_for_job(self).fail!
    ExceptionNotifier.notify_exception(exception, data: {job: to_yaml})
    raise exception
  end

  private

  def task_for_job(job)
    Task.find(job.arguments.first[:task_id])
  end
end