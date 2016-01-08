# == Schema Information
#
# Table name: project_steps
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  project_type    :string
#  agent_id        :integer
#  scheduled_date  :date
#  completed_date  :date
#  is_finalized    :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  step_type_value :string
#
# Indexes
#
#  index_project_steps_on_agent_id                     (agent_id)
#  index_project_steps_on_project_type_and_project_id  (project_type,project_id)
#

FactoryGirl.define do
  factory :project_step do
    project { create(:loan) }
    agent { create(:person) }
    # for now, saved below in after(:create) block
    # summary { Faker::Lorem.sentence }
    # details { Faker::Lorem.paragraph }
    scheduled_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    is_finalized [true, false].sample
    step_type_value { ['step', 'milestone']  }

    # for now parent must be saved before assigning the translatable fields
    after(:create) do |log|
      log.set_summary(Faker::Lorem.sentences)
      log.set_details(Faker::Lorem.paragraphs)
    end


    trait :completed do
      completed_date { Faker::Date.between(scheduled_date, Date.today) }
    end

    trait :past do
      scheduled_date { Faker::Date.backward }
    end

    trait :future do
      scheduled_date { Faker::Date.forward }
    end

    trait :with_logs do
      after(:create) do |step|
        create_list(
          :project_log,
          num_logs = 2,
          project_step: step
        )
      end
    end
  end
end
