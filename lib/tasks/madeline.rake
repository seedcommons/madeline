namespace :madeline do
  desc "Enqueue the interest accrual Task. The whenever gem runs this rake task monthly."
  # Note the Madeline Task model is a completely separate concept from a rake task
  task enqueue_monthly_interest_accrual_task: :environment do
    Task.create(
      job_class: MonthlyInterestAccrualJob,
      job_type_value: 'monthly_interest_accrual_job',
      activity_message_value: 'updating loans'
    ).enqueue
  end
end
