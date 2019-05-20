class TaskMonitorJob < ApplicationJob
  def perform
    Sidekiq::RetrySet.new.each do |item|
      task = task_for_item(item)
      if task.present?
        retried_at = item["retried_at"]
        error_message = item["error_message"]
        error_class = item["error_class"]
        task.update_attributes!(
          {
            job_retried_at: Time.zone.at(retried_at).to_datetime,
            activity_message_value: "#{error_class}: #{error_message}"
          }
        )
      end
    end
  end

  private

  def task_for_item(item)
    if item.args.length > 0 &&
        item.args.first.key?("arguments") &&
        item["args"][0]["arguments"].length > 0 &&
        item["args"][0]["arguments"][0].key?("task_id")
      task_id = item["args"][0]["arguments"][0]["task_id"]
      if task_id && Task.exists?(task_id)
        Task.find(task_id)
      end
    end
  end
end
