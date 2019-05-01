# == Schema Information
#
# Table name: tasks
#
#  activity_message_value    :string(65536)    not null
#  id                        :bigint(8)        not null, primary key
#  job_class                 :string(255)      not null
#  job_enqueued_for_retry_at :datetime
#  job_first_started_at      :datetime
#  job_last_failed_at        :datetime
#  job_succeeded_at          :datetime
#  job_type_value            :string(255)      not null
#  num_attempts              :integer          default(0), not null
#  provider_job_id           :string
#

class Task < ApplicationRecord
  def enqueue
    job = job_class.constantize.perform_later(task_id: id)
    self.update_attribute(:provider_job_id, job.provider_job_id)
  end

  def status
    if pending?
      :pending
    elsif in_progress?
      :in_progress
    elsif succeeded?
      :succeeded
    elsif stalled?
      :stalled
    end
  end

  def start
    self.update_attribute(:job_first_started_at, Time.current) if self.job_first_started_at.nil?
    self.increment(:num_attempts, by = 1).save
  end

  def end_successfully
    self.update_attribute(:job_succeeded_at, Time.current)
  end

  def record_failure
    self.update_attribute(:job_last_failed_at, Time.current)
  end

  protected

  def waiting_for_retry?
    job_enqueued_for_retry_at.present? && job_first_started_at.present? && job_enqueued_for_retry_at > job_first_started_at
  end

  private

  def pending?
    job_first_started_at.nil?
  end

  def in_progress?
    job_first_started_at.present? && job_succeeded_at.nil? && !waiting_for_retry?
  end

  def succeeded?
    job_first_started_at.present? && job_succeeded_at.present?
  end

  def stalled?
    job_first_started_at.present? && job_succeeded_at.nil? && waiting_for_retry?
  end
end
