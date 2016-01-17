# == Schema Information
#
# Table name: project_logs
#
#  id                    :integer          not null, primary key
#  project_step_id       :integer
#  agent_id              :integer
#  date                  :date
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  progress_metric_value :string
#
# Indexes
#
#  index_project_logs_on_agent_id         (agent_id)
#  index_project_logs_on_project_step_id  (project_step_id)
#

FactoryGirl.define do
  factory :project_log do
    project_step
    agent { create(:person) }
    date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today)}
    progress_metric_value { ['behind', 'ontime', 'ahead'].sample }

    # for now parent must be saved before assigning the translatable fields
    after(:create) do |log|
      log.set_summary(Faker::Lorem.sentences(3))
      log.set_details(Faker::Lorem.paragraphs(3))
      log.set_additional_notes(Faker::Lorem.sentences(3))
      log.set_private_notes(Faker::Lorem.paragraph)
    end

  end
end
