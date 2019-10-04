# == Schema Information
#
# Table name: tasks
#
#  activity_message_data  :json
#  activity_message_value :string(65536)    not null
#  created_at             :datetime         not null
#  custom_error_data      :json
#  id                     :bigint(8)        not null, primary key
#  job_class              :string(255)      not null
#  job_first_started_at   :datetime
#  job_last_failed_at     :datetime
#  job_succeeded_at       :datetime
#  job_type_value         :string(255)      not null
#  num_attempts           :integer          default(0), not null
#  provider_job_id        :string
#  taskable_id            :bigint(8)
#  taskable_type          :string
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_tasks_on_taskable_type_and_taskable_id  (taskable_type,taskable_id)
#

class Task < ApplicationRecord
  TASK_JOB_TYPES = %i(full_fetcher)

  belongs_to :taskable, polymorphic: true

  scope :full_fetcher, -> { where(job_type_value: :full_fetcher) }
  scope :by_creation_time, ->(direction = :asc) { order(created_at: direction) }

  def enqueue(job_params: {})
    job = job_class.constantize.perform_later(job_params.merge(task_id: id))
    self.update_attribute(:provider_job_id, job.provider_job_id)
  end

  def status
    if pending?
      :pending
    elsif in_progress?
      :in_progress
    elsif succeeded?
      :succeeded
    elsif failed?
      :failed
    end
  end

  def duration
    case status
    when :pending, :in_progress
      Time.zone.now - created_at
    when :succeeded
      job_succeeded_at - created_at
    when :failed
      job_last_failed_at - created_at
    end
  end

  def start!
    self.update_attribute(:job_first_started_at, Time.current) if self.job_first_started_at.nil?
    self.increment(:num_attempts).save
  end

  def finish!
    self.update_attribute(:job_succeeded_at, Time.current)
  end

  def fail!
    self.update_attribute(:job_last_failed_at, Time.current)
  end

  def succeeded?
    job_succeeded_at.present?
  end

  # Supports interpolating data only available within the task job
  def set_activity_message(message, data = nil)
    self.update(activity_message_value: message, activity_message_data: data)
  end

  def activity_message
    I18n.t("task.activity_message.#{activity_message_value}", activity_message_data.try(:symbolize_keys))
  end

  private

  def pending?
    job_first_started_at.nil?
  end

  def in_progress?
    job_first_started_at.present? &&
      job_succeeded_at.nil? &&
      job_last_failed_at.nil?
  end

  def failed?
    job_last_failed_at.present? && job_succeeded_at.nil?
  end
end
