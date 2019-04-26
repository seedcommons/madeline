class  TaskJob < ApplicationJob
  before_perform do |job|
    task_for_job(job).update_attribute(:job_started_at, Time.current)
  end

  def perform(args)
    perform_task_job(args)
    task_for_job(self).update_attribute(:job_completed_at, Time.current)
  end

  def perform_task_job(args)
    puts "perform task job in task job"
    raise NotImplementedError
  end

  private

  def task_for_job(job)
    Task.find(job.arguments.first[:task_id])
  end
end
