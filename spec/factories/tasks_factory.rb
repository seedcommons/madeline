FactoryBot.define do
  factory :task do
    job_type_value { "monthly_interest_accrual_job" }
    activity_message_value { "running monthly interest accrual" }
    job_class { MonthlyInterestAccrualJob }
  end
end
