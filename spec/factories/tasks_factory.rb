# == Schema Information
#
# Table name: tasks
#
#  id                     :bigint           not null, primary key
#  activity_message_data  :json
#  activity_message_value :string(65536)    not null
#  custom_error_data      :json
#  job_class              :string(255)      not null
#  job_first_started_at   :datetime
#  job_last_failed_at     :datetime
#  job_succeeded_at       :datetime
#  job_type_value         :string(255)      not null
#  num_attempts           :integer          default(0), not null
#  taskable_type          :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider_job_id        :string
#  taskable_id            :bigint
#
# Indexes
#
#  index_tasks_on_taskable_type_and_taskable_id  (taskable_type,taskable_id)
#
FactoryBot.define do
  factory :task do
    job_type_value { "update_all_loans" }
    activity_message_value { "test_activity_message_value" }
    job_class { UpdateAllLoansJob }
  end
end
