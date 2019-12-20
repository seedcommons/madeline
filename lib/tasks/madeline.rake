namespace :madeline do
  # Note the Madeline Task model is a completely separate concept from a rake task
  desc "Update all loans. The whenever gem runs this rake task at least daily."

  task enqueue_update_loans_task: :environment do
    Task.create(
      job_class: UpdateAllLoansJob,
      job_type_value: 'update_all_loans',
      activity_message_value: 'task_enqueued'
    ).enqueue
  end
end
