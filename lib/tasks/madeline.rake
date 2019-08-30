namespace :madeline do
  desc "Enqueue the interest accrual Task. The whenever gem runs this rake task monthly."
  # Note the Madeline Task model is a completely separate concept from a rake task
  task enqueue_monthly_interest_accrual_task: :environment do
    Task.create(
      job_class: MonthlyInterestAccrualJob,
      job_type_value: 'monthly_interest_accrual_job',
      activity_message_value: 'task_enqueued'
    ).enqueue
  end

  desc "for testing update loan task"

  task update_loans_task: :environment do
    Task.create(
      job_class: UpdateAllLoansJob,
      job_type_value: 'update_all_loans_job',
      activity_message_value: 'task_enqueued'
    ).enqueue
  end
end
