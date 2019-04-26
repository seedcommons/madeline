class  TaskJob < ApplicationJob
  before_perform do |job|
    task_for_job(job).update_attribute(:job_started_at, Time.current)
  end

  def perform(args)
    perform_task_job(args)
    task_for_job(self).update_attribute(:job_completed_at, Time.current)
  end

  def perform_task_job(args)
    raise NotImplementedError
  end

  rescue_from(StandardError) do |exception|
    task_for_job(self).update_attribute(:job_failed_at, Time.current)
    super
  end

  private

  def task_for_job(job)
    Task.find(job.arguments.first[:task_id])
  end
end
