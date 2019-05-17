class TaskMonitorJob < ApplicationJob
  def perform
    Sidekiq::RetrySet.new.each do |item|
      task_id = item["args"][0]["arguments"][0]["task_id"]
      Rails.logger.error "task id: #{task_id}"
      if task_id && Task.exists?(task_id)
        last_enqueued_at = item["enqueued_at"]
        error_message = item["error_message"]
        Rails.logger.error "last enqueued at: #{last_enqueued_at}"
        Task.find(task_id).update_attributes!(
          {
            job_enqueued_for_retry_at: Time.at(last_enqueued_at).to_datetime,
            activity_message_value: error_message
          }
        )
      end
    end
  end
end
