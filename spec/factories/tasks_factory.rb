FactoryBot.define do
  factory :task do
    job_type_value { "monthly_interest_accrual_job" }
    activity_message_value { "test_activity_message_value" }
    job_class { MonthlyInterestAccrualJob }
  end
end
