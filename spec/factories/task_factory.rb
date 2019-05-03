# == Schema Information
#
# Table name: tasks
#
#  activity_message_value    :string(65536)    not null
#  id                        :bigint(8)        not null, primary key
#  job_class                 :string(255)      not null
#  job_enqueued_for_retry_at :datetime
#  job_first_started_at      :datetime
#  job_last_failed_at        :datetime
#  job_succeeded_at          :datetime
#  job_type_value            :string(255)      not null
#  num_attempts              :integer          default(0), not null
#  provider_job_id           :string
#

FactoryBot.define do
  factory :task do
    job_type_value { "monthly_interest_accrual_job" }
    activity_message_value { "running monthly interest accrual" }
    job_class { MonthlyInterestAccrualJob }
  end
end
