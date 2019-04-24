class Task < ApplicationRecord
  def enqueue
    job = job_class.constantize.perform_later(task_id: id)
    pp "ENQUEUE"
    pp jobs
    self.update_attribute(:provider_job_id, job.provider_job_id)
  end

  def status
    :pending
  end
end
