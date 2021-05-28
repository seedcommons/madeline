class TaskJob < ApplicationJob
  around_perform do |job, perform_block|
    task_for_job(job).start!
    perform_block.call
    task_for_job(job).finish!
  end

  rescue_from(StandardError) do |error|
    task_for_job(self).set_activity_message("failed")
    task_for_job(self).fail!
    ExceptionNotifier.notify_exception(error, data: {job: to_yaml})
    raise error
  end

  private

  def task
    @task ||= task_for_job(self)
  end

  def task_for_job(job)
    Task.find(job.arguments.first[:task_id])
  end
end
