FactoryBot.define do
  factory :task do
    job_type_value { "recalculate_loan_health_job" }
    activity_message_value { "pending" }
  end
end
