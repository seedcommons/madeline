FactoryBot.define do
  factory :task do
    job_type_value { "update_all_loans" }
    activity_message_value { "test_activity_message_value" }
    job_class { UpdateAllLoansJob }
  end
end
