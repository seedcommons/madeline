# == Schema Information
#
# Table name: tasks
#
#  activity_message_value    :string(65536)    not null
#  id                        :bigint(8)        not null, primary key
#  job_class                 :string(255)      not null
#  job_completed_at          :datetime
#  job_enqueued_for_retry_at :datetime
#  job_failed_at             :datetime
#  job_started_at            :datetime
#  job_type_value            :string(255)      not null
#  provider_job_id           :string
#

FactoryBot.define do
  factory :task do
    job_type_value { "recalculate_loan_health_job" }
    activity_message_value { "recalculating loan health" }
    job_class { RecalculateLoanHealthJob }
  end
end
